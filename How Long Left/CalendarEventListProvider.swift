//
//  CalendarEventListProvider.swift
//  How Long Left
//
//  Created by Ryan on 3/1/2025.
//

import Foundation
import HowLongLeftKit
import EventKit
import Combine

@MainActor
class CalendarEventListProvider: ObservableObject {
    
    @Published var eventList: [CalendarEventContainer] = []
    private var cancellables: Set<AnyCancellable> = []
    private var pointStore: TimePointStore
    
    init(pointStore: TimePointStore) {
        self.pointStore = pointStore
        self.eventList = getEventList()
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Subscribe to changes in pointStore
        pointStore.objectWillChange
            .sink { [weak self] _ in
                self?.updateEventList()
            }
            .store(in: &cancellables)
    }
    
    private func updateEventList() {
        self.eventList = getEventList()
    }
    
    func getEventList() -> [CalendarEventContainer] {
        guard let calendars = pointStore.eventCache.getAllowedCalendars() else {
           return []
        }
        
        var containersWithEvents: [CalendarEventContainer] = []
        var containersWithoutEvents: [CalendarEventContainer] = []
        
        let currentPoint = pointStore.currentPoint
        
        for calendar in calendars {
            if let event = currentPoint?.fetchSingleEvent(accordingTo: .preferInProgress, for: calendar.calendarIdentifier) {
                print("Creating CalendarEventContainer with event \(event.title)")
                containersWithEvents.append(CalendarEventContainer(calendar: calendar, event: event))
                
            } else {
                print("Creating CalendarEventContainer without event")
                containersWithoutEvents.append(CalendarEventContainer(calendar: calendar, event: nil))
            }
        }
        
        // Sort containers with events by the event's start date
        containersWithEvents.sort { lhs, rhs in
            guard let lhsEventStart = lhs.event?.startDate, let rhsEventStart = rhs.event?.startDate else {
                return false
            }
            return lhsEventStart < rhsEventStart
        }
        
        // Combine the two lists: events first, no-events last
        return containersWithEvents + containersWithoutEvents
    }
}

@MainActor
class MockCalendarEventListProvider: CalendarEventListProvider {
    
    private let generator: MockEventDataGenerator
    
    init(generator: MockEventDataGenerator = MockEventDataGenerator(), timePointStore: TimePointStore) {
        self.generator = generator
        super.init(pointStore: timePointStore) // Replace with an appropriate mock or stub for TimePointStore
        self.eventList = getEventList()
    }
    
    override func getEventList() -> [CalendarEventContainer] {
        return generator.getFirstEventFromEachCalendar()
    }
}
