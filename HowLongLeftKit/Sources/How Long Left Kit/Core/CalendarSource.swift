//
//  CalendarReader.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
import EventKit
import CryptoKit
import SwiftUI
import Combine

@MainActor
public class CalendarSource: ObservableObject {
    
    @MainActor
    private let eventStore = EKEventStore()
    private let eventChangedSubject = PassthroughSubject<Void, Never>()
    
    public var eventChangedPublisher: AnyPublisher<Void, Never> {
        eventChangedSubject.eraseToAnyPublisher()
    }
    
    @Published public var calendarAccessDenied: Bool = false
    
    public var authorization: EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    @MainActor
    public init(requestCalendarAccessImmediately request: Bool) {
        if request {
            Task {
                await requestCalendarAccess()
            }
        }
        setupNotificationSubscription()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .EKEventStoreChanged, object: nil)
    }
    
    @MainActor
    public func requestCalendarAccess() async -> Bool {
        let accessStore = EKEventStore()
        var optionalResult: Bool?
        
        if #available(macOS 14.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            optionalResult = try? await accessStore.requestFullAccessToEvents()
        } else {
            optionalResult = try? await accessStore.requestAccess(to: .event)
        }
        
        let result = optionalResult ?? false
        
        print("Calendar access \(result ? " granted" : " denied")")
        
        self.eventStore.reset()
        
        
        
        
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.calendarAccessDenied = false
            
        } else {
            
            switch EKEventStore.authorizationStatus(for: .event) {
                
            case .notDetermined:
                self.calendarAccessDenied = false
            case .restricted:
                self.calendarAccessDenied = true
            case .denied:
                self.calendarAccessDenied = true
            case .fullAccess:
                self.calendarAccessDenied = false
            case .writeOnly:
                self.calendarAccessDenied = true
            @unknown default:
                self.calendarAccessDenied = true
            }
            
        }
    
        self.objectWillChange.send()
        self.eventChangedSubject.send()
        return result
    }
    
    func getEvents(from calendars: [HLLCalendar]) -> EventFetchResult {
        let ekCalendars = calendars.compactMap { lookupEkCalendar(withID: $0.calendarIdentifier) }
        
        if ekCalendars.isEmpty {
            return EventFetchResult(events: [], calendars: [])
        }

        let calendar = Calendar.current
        let now = Date()
        let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -2, to: now)!)
        let endDate = calendar.date(byAdding: .day, value: 14, to: now)!
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
        let request = eventStore.predicateForEvents(withStart: start, end: end, calendars: ekCalendars)
        let events = eventStore.events(matching: request).map { HLLCalendarEvent(event: $0) }
        return EventFetchResult(events: events, calendars: calendars, predicateStart: start, predicateEnd: end)
    }
    
    public func lookupCalendar(withID id: String) -> HLLCalendar? {
        if let calendar = lookupEkCalendar(withID: id) {
            return HLLCalendar(ekCalendar: calendar)
        }
        return nil
    }
    
    private func lookupEkCalendar(withID id: String) -> EKCalendar? {
        if let calendar = eventStore.calendar(withIdentifier: id) {
            return calendar
        }
        return nil
    }
    
    public func getAllHLLCalendars() -> [HLLCalendar] {
        return self.eventStore.calendars(for: .event).map { HLLCalendar(ekCalendar: $0) }
    }
    
    public func getColor(calendarID: String) -> Color {
        if let col = self.lookupCalendar(withID: calendarID)?.color {
            return col
        }
        return .primary
    }
    
    private func setupNotificationSubscription() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(eventStoreChanged),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }
    
    @objc private func eventStoreChanged() {
        print("Event store changed")
        eventChangedSubject.send()
    }
    
    public enum Authorization {
        case notDetermined
        case notAuthorized
        case authorized
    }
    
}

@MainActor
public protocol EventSource {
    func requestCalendarAccess() -> Bool
    func getAllHLLCalendars() -> [HLLCalendar]
    func getColor(calendarID: String) -> Color
}
