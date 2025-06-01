//
//  CalendarEventCache.swift
//  How Long Left Kit
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
import EventKit
@preconcurrency import Combine
import os.log
import CryptoKit
import Defaults
import SwiftUI

@MainActor
public class CalendarEventCache: ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "EventCache")
    
    private var eventCache: [HLLCalendarEvent]?
    public var cacheSummaryHash: String?
    
    private var stale = true
    private var calendarContexts: Set<String>
    
    private var eventStoreSubscription: AnyCancellable?
    private var hiddenEventManagerSubscription: AnyCancellable?
    private var calendarPrefsSubscription: AnyCancellable?
    private var calendarSourceSubscription: AnyCancellable?
    
    private var fetchDataKey: Defaults.Key<String?>
    
    private var updatesCache: Bool
    
    private weak var calendarReader: CalendarSource?
    public weak var calendarProvider: (any CalendarSettingsProvider)? {
        didSet { setupCalendarsSubscription() }
    }
    private weak var hiddenEventManager: StoredEventManager? {
        didSet { setupHiddenEventManagerSubscription() }
    }
    
    let queue = DispatchQueue(label: "com.ryankontos.howlongleft_eventcachequeue")
    
    public var id: String
    
    public init(calendarReader: CalendarSource?,
                calendarProvider: any CalendarSettingsProvider,
                calendarContexts: Set<String>,
                hiddenEventManager: StoredEventManager,
                id: String, updatesCache: Bool = false) {
        
        self.calendarReader = calendarReader
        self.calendarProvider = calendarProvider
        self.calendarContexts = calendarContexts
        self.hiddenEventManager = hiddenEventManager
        self.id = id
        
        self.updatesCache = updatesCache
        
        fetchDataKey = Defaults.Key<String?>("\(id)_LatestFetchData", suite: sharedDefaults, default: { nil })
        
        setupSubscriptions()
        Task {
            updateEvents()
        }
    }
    
    // MARK: - Setup Functions
    
    private func setupSubscriptions() {
        setupCalendarsSubscription()
        setupHiddenEventManagerSubscription()
        setupCalendarSourceSubscription()
    }
    
    private func setupCalendarsSubscription() {
        guard let calendarProvider else { return }
        calendarPrefsSubscription?.cancel()
        calendarPrefsSubscription = calendarProvider.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateEvents()
                }
            }
    }
    
    private func setupHiddenEventManagerSubscription() {
        guard let hiddenEventManager else { return }
        hiddenEventManagerSubscription?.cancel()
        hiddenEventManagerSubscription = hiddenEventManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateEvents()
            }
    }
    
    private func setupCalendarSourceSubscription() {
        guard let reader = calendarReader else { return }
        calendarSourceSubscription?.cancel()
        calendarSourceSubscription = reader.eventChangedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.stale = true
                self?.logger.debug("Received eventChanged notification from CalendarSource")
                self?.updateEvents()
            }
    }
    
    // MARK: - Event Update Logic
    
    func getEvents() async -> [HLLCalendarEvent] {
        if eventCache == nil || stale {
            updateEvents()
        }
        return eventCache ?? []
    }
    
    public func getAllowedCalendars() -> [HLLCalendar]? {
        return calendarProvider?.getAllowedCalendars(matchingContextIn: calendarContexts)
    }
    
    private func updateEvents() {
        logger.debug("Updating events")

        if !stale && eventCache != nil {
            logger.debug("No changes detected, skipping update")
            return
        }

        guard
            let calendarProvider,
            let calendarReader,
            let hiddenEventManager
        else {
            logger.error("Missing required components for event update")
            return
        }

        // 1. Fetch all source events
        let fetchResult = calendarReader.getEvents(
            from: calendarProvider.getAllowedCalendars(matchingContextIn: calendarContexts)
        )
        let allSourceEvents = fetchResult.events
            .filter { calendarProvider.getAllDayAllowed() || !$0.isAllDay }

        // 2. Deduplicate source events up front
        var uniqueSourceEvents: [HLLCalendarEvent] = []
        var seenIDs = Set<String>()
        for event in allSourceEvents {
            if seenIDs.insert(event.eventIdentifier).inserted {
                uniqueSourceEvents.append(event)
            } else {
                logger.warning("Duplicate in sourceEvents for \(event.eventIdentifier), skipping")
            }
        }

        // 3. Build lookup of old cache, ignoring duplicates (keep first)
        let oldCache = eventCache ?? []
        let oldLookup = Dictionary(
            oldCache.map { ($0.eventIdentifier, $0) },
            uniquingKeysWith: { first, _ in
                logger.warning("Duplicate in oldCache for \(first.eventIdentifier), keeping the first one")
                return first
            }
        )

        // 4. Prepare new cache and change-flag
        var updatedCache: [HLLCalendarEvent] = []
        var didChange = false
        var leftoverOld = oldLookup

        // 5. Walk through the source events
        for source in uniqueSourceEvents {
            let id = source.eventIdentifier

            // Skip hidden events
            if hiddenEventManager.isEventStoredWith(eventID: id) {
                continue
            }

            if var existing = leftoverOld[id] {
                if updateEvent(&existing, from: source) {
                    didChange = true
                    logger.debug("Updated event in place: \(id)")
                }
                updatedCache.append(existing)
                leftoverOld.removeValue(forKey: id)
            } else {
                updatedCache.append(source)
                didChange = true
                logger.debug("Added new event to cache: \(id)")
            }
        }

        // 6. Remove any stale events
        if !leftoverOld.isEmpty {
            didChange = true
            logger.debug("Removed \(leftoverOld.count) stale events from cache")
        }

        // 7. Finalise cache update if changed
        if didChange {
            eventCache = updatedCache
            cacheSummaryHash = String(fetchResult.getHash())
            stale = false
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            logger.debug("Event cache updated (\(updatedCache.count) events)")
        }
    }
    private func updateEvent(_ event: inout HLLCalendarEvent, from ekEvent: HLLCalendarEvent) -> Bool {
        var changes = false
        updateIfNeeded(&event.title, compareTo: ekEvent.title, flag: &changes)
        updateIfNeeded(&event.startDate, compareTo: ekEvent.startDate, flag: &changes)
        updateIfNeeded(&event.endDate, compareTo: ekEvent.endDate, flag: &changes)
        updateIfNeeded(&event.calendar, compareTo: ekEvent.calendar, flag: &changes)
        updateIfNeeded(&event.structuredLocation, compareTo: ekEvent.structuredLocation, flag: &changes)
        return changes
    }
    
    deinit {
        calendarPrefsSubscription?.cancel()
        hiddenEventManagerSubscription?.cancel()
        calendarSourceSubscription?.cancel()
        logger.debug("EventCache deinitialized")
    }
}
