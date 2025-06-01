//
//  CalendarSettingsStore.swift
//  How Long Left Kit
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
import Defaults
import Combine
import EventKit
import CoreData
import os.log

public class CalendarSettingsStore: ObservableObject, CalendarSettingsProvider {
  
    public struct Configuration {
        public init(domain: String, defaultContextsForNonMatches: Set<String>) {
            self.domain = domain
            self.defaultContextsForNonMatches = defaultContextsForNonMatches
            self.allowAllDayKey = Defaults.Key<Bool>("HLL_EventFiltering_\(domain)_AllowAllDayEvents", default: true)
        }
        
        public let allowAllDayKey: Defaults.Key<Bool>
        
        var domain: String
        var defaultContextsForNonMatches: Set<String>
    }
    
 
    static let context = HLLPersistenceController.shared.viewContext

    public var configuration: Configuration
    public var calendarItems: [CalendarInfo] = []
    
    private let calendarSource: CalendarSource
    private var domainObject: CalendarStorageDomain?
    @MainActor
    private var cancellables: Set<AnyCancellable> = []
    
    private let logger: Logger
    
    public init(calendarSource: CalendarSource, config: Configuration) {
        self.configuration = config
        self.calendarSource = calendarSource
        
        self.logger = Logger(subsystem: "howlongleftmac.eventfetchsettingsmanager", category: "\(config.domain)")
        
        fetchOrCreateDomainObject()
        syncCalendarsWithDomain()
        updateCalendarItems()
        updateSubscriptions()
        
        Task {
            for await _ in Defaults.updates(config.allowAllDayKey) {
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send()
                }
            }
        }
        
    }
    
    private func fetchOrCreateDomainObject() {
        let fetchRequest: NSFetchRequest<CalendarStorageDomain> = CalendarStorageDomain.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "domainID == %@", configuration.domain)
        
        do {
            let results = try Self.context.fetch(fetchRequest)
            if let existingDomain = results.first {
                self.domainObject = existingDomain
            } else {
                let newDomain = CalendarStorageDomain(context: Self.context)
                newDomain.domainID = configuration.domain
                self.domainObject = newDomain
                try Self.context.save()
            }
        } catch {
            handleError(error, message: "Error fetching or saving domain object")
        }
    }
    
    public func syncCalendarsWithDomain() {
        guard let domainObject = self.domainObject else { return }
        
        let allCalendars = calendarSource.getAllHLLCalendars()
        let fetchRequest: NSFetchRequest<CalendarInfo> = CalendarInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "domain == %@", domainObject)
        
        do {
            let existingCalendarInfos = try Self.context.fetch(fetchRequest)
            
            for ekCalendar in allCalendars {
                if let match = existingCalendarInfos.first(where: { $0.id == ekCalendar.calendarIdentifier }) ?? existingCalendarInfos.first(where: { $0.title == ekCalendar.title }) {
                    if match.id != ekCalendar.calendarIdentifier || match.title != ekCalendar.title {
                        match.id = ekCalendar.calendarIdentifier
                        match.title = ekCalendar.title
                    }
                } else {
                    let newCalendarInfo = CalendarInfo(context: Self.context)
                    newCalendarInfo.id = ekCalendar.calendarIdentifier
                    newCalendarInfo.title = ekCalendar.title
                    newCalendarInfo.domain = domainObject

                    for context in configuration.defaultContextsForNonMatches {
                        let newContext = CalendarContext(context: Self.context)
                        newContext.id = context
                        newContext.calendar = newCalendarInfo
                        newCalendarInfo.addToContexts(newContext)
                    }
                }
            }
            
            try Self.context.save()
            updateCalendarItems()
        } catch {
            handleError(error, message: "Error syncing calendars with domain")
        }
    }
    
    private func updateCalendarItems() {
        guard let domainObject = self.domainObject else { return }
        
        let fetchRequest: NSFetchRequest<CalendarInfo> = CalendarInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "domain == %@", domainObject)
        
        do {
            let existingCalendarInfos = try Self.context.fetch(fetchRequest)
            let allCalendars = calendarSource.getAllHLLCalendars()
            let allowedCalendarIds = Set(allCalendars.map { $0.calendarIdentifier })
            
            var validCalendarInfos = existingCalendarInfos.filter { allowedCalendarIds.contains($0.id ?? "") }
            validCalendarInfos.sort { $0.title ?? "" < $1.title ?? "" }
            self.calendarItems = validCalendarInfos
            
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
                self?.updateSubscriptions()
            }
            
        } catch {
            handleError(error, message: "Error updating calendar items")
        }
    }
    
    public func getAllDayAllowed() -> Bool {
        return Defaults[configuration.allowAllDayKey]
    }
    
    private func updateSubscriptions() {
        // Cancel all previous subscriptions
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        // Subscribe to CalendarSource's eventChangedPublisher
        calendarSource.eventChangedPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.updateCalendarItems()
                self.syncCalendarsWithDomain()
            }
            .store(in: &cancellables)
    }
    
    private func calendarInfoDidChange(_ calendarInfo: CalendarInfo) {
        syncCalendarsWithDomain()
        updateCalendarItems()
        objectWillChange.send()
    }
    
    public func fetchAllowedCalendarInfos(matchingContextIn contexts: Set<String>) throws -> [CalendarInfo] {

        guard let domainObject = self.domainObject else { return [] }
       
        let fetchRequest: NSFetchRequest<CalendarInfo> = CalendarInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "domain == %@", domainObject)
       
        return try CalendarSettingsStore.context.performAndWait {
            
            let existingCalendarInfos = try Self.context.fetch(fetchRequest)
            let allowedCalendarInfos = existingCalendarInfos.filter { calendarInfo in
                guard let calendarContexts = calendarInfo.contexts as? Set<CalendarContext> else {
                    return false
                }
                
                let calendarContextIds = calendarContexts.compactMap { $0.id }
                return contexts.isSubset(of: calendarContextIds)
            }
            
            return allowedCalendarInfos
        }
        
    }
    
    public func getAllowedCalendars(matchingContextIn contexts: Set<String>) -> [HLLCalendar] {
        guard self.domainObject != nil else { return [] }
        
        do {
            let allowedCalendarInfos = try fetchAllowedCalendarInfos(matchingContextIn: contexts)
            let allowedCalendarIds = Set(allowedCalendarInfos.compactMap { $0.id })
            
            let allCalendars = calendarSource.getAllHLLCalendars()
            return allCalendars.filter { allowedCalendarIds.contains($0.calendarIdentifier) }
        } catch {
            handleError(error, message: "Error fetching allowed calendars")
            return []
        }
    }
    
    public func updateForNewCals() {
        syncCalendarsWithDomain()
    }
}

extension CalendarSettingsStore {
    
    public func getHLLCalendar(for calendarInfo: CalendarInfo) -> HLLCalendar? {
        
        guard let calendarID = calendarInfo.id else {
            return nil
        }
        
        let allCalendars = calendarSource.getAllHLLCalendars()
            return allCalendars.first { $0.calendarIdentifier == calendarID }
    }
    
    // Checks if a CalendarInfo object already contains a specific context ID
    public func containsContext(calendarInfo: CalendarInfo, contextID: String) -> Bool {
        guard let contexts = calendarInfo.contexts as? Set<CalendarContext> else { return false }
        return contexts.contains { $0.id == contextID }
    }
    
    public func containsContexts(calendarInfo: CalendarInfo, contextIDs: Set<String>) -> Bool {
        guard let contexts = calendarInfo.contexts as? Set<CalendarContext> else { return false }
        let contextIDsSet = Set(contextIDs)
        let matchingContextIDs = contexts.compactMap { $0.id }
        return contextIDsSet.isSubset(of: matchingContextIDs)
    }
    
    public func updateContexts(for calendarInfo: CalendarInfo, addContextIDs: Set<String>? = nil, removeContextIDs: Set<String>? = nil, notify: Bool = true) {
        guard self.domainObject != nil else { return }

        // Determine the contexts to actually add and remove, avoiding conflicts
        let actualAddContextIDs = addContextIDs?.subtracting(removeContextIDs ?? []) ?? []
        let actualRemoveContextIDs = removeContextIDs?.subtracting(addContextIDs ?? []) ?? []
        
        // Handle adding contexts
        for contextID in actualAddContextIDs {
            if containsContext(calendarInfo: calendarInfo, contextID: contextID) {
                ////print("Context \(contextID) already exists in CalendarInfo \(calendarInfo.title ?? "unknown")")
                continue
            }

            let newContext = CalendarContext(context: Self.context)
            newContext.id = contextID
            newContext.calendar = calendarInfo
            
            calendarInfo.addToContexts(newContext)
        }
        
        // Handle removing contexts
        if let contexts = calendarInfo.contexts as? Set<CalendarContext> {
            for contextID in actualRemoveContextIDs {
                if !containsContext(calendarInfo: calendarInfo, contextID: contextID) {
                    continue
                }

                if let contextToRemove = contexts.first(where: { $0.id == contextID }) {
                    Self.context.delete(contextToRemove)
                }
            }
        }
        
        if notify {
            self.saveContext()
            self.updateCalendarItems()
        }
        
    }
    
    public func batchUpdateContexts(addContextIDs: Set<String>? = nil, removeContextIDs: Set<String>? = nil) {
        
        for item in self.calendarItems {
            updateContexts(for: item, addContextIDs: addContextIDs, removeContextIDs: removeContextIDs, notify: false)
        }
        
        self.saveContext()
        self.updateCalendarItems()
    }

    private func saveContext() {
        do {
            try Self.context.save()
        } catch {
            handleError(error, message: "Error saving context")
        }
    }
    
    private func handleError(_ error: Error, message: String) {
        // Here we can use a logging framework or any error handling strategy
        ////print("\(message): \(error)")
    }
}
