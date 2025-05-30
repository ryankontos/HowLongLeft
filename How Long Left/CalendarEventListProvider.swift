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
import Defaults

@MainActor
class CalendarEventListProvider: ObservableObject {
    
    @Published var containersWithEvent: [CalendarEventContainer] = []
    @Published var containersWithoutEvent: [CalendarEventContainer] = []
    @Published var listShowEmptyCalendars: Bool = Defaults[.listShowEmptyCalendars] {
        didSet {
            updateContainers()
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    private var pointStore: TimePointStore
    
    init(pointStore: TimePointStore) {
        self.pointStore = pointStore
        setupBindings()
        
        Task {
            for await value in Defaults.updates(.listShowEmptyCalendars) {
                self.listShowEmptyCalendars = value
            }
        }
        
        updateContainers()
    }
    
    private func setupBindings() {
        pointStore.objectWillChange
            .sink { [weak self] _ in
                self?.updateContainers()
            }
            .store(in: &cancellables)
    }
    
    func updateContainers() {
        let (withEvent, withoutEvent) = getContainers()
        self.containersWithEvent = sortEventContainers(withEvent)
        self.containersWithoutEvent = listShowEmptyCalendars ? withoutEvent : []
    }
    
    func getContainers() -> ([CalendarEventContainer], [CalendarEventContainer]) {
        guard let calendars = pointStore.eventCache.getAllowedCalendars() else {
            return ([], [])
        }
        
        var withEvent: [CalendarEventContainer] = []
        var withoutEvent: [CalendarEventContainer] = []
        
        let currentPoint = pointStore.currentPoint
        
        for calendar in calendars {
            if let event = currentPoint?.fetchSingleEvent(accordingTo: .inProgressOnly, for: calendar.calendarIdentifier) {
                withEvent.append(CalendarEventContainer(calendar: calendar, event: event))
            } else {
                withoutEvent.append(CalendarEventContainer(calendar: calendar, event: nil))
            }
        }
        
        return (withEvent, withoutEvent)
    }
    
    func sortEventContainers(_ containers: [CalendarEventContainer]) -> [CalendarEventContainer] {
        return containers.sorted { lhs, rhs in
            guard let lhsEventStart = lhs.event?.startDate, let rhsEventStart = rhs.event?.startDate else {
                return false
            }
            return lhsEventStart < rhsEventStart
        }
    }
}

@MainActor
class MockCalendarEventListProvider: CalendarEventListProvider {
    
    private let generator: MockEventDataGenerator
    
    init(generator: MockEventDataGenerator = MockEventDataGenerator(), timePointStore: TimePointStore) {
        self.generator = generator
        super.init(pointStore: timePointStore)
        updateContainers()
    }
    
    override func getContainers() -> ([CalendarEventContainer], [CalendarEventContainer]) {
        let mockContainers = generator.getFirstEventFromEachCalendar()
        let withEvent = mockContainers.filter { $0.event != nil }
        let withoutEvent = mockContainers.filter { $0.event == nil }
        return (sortEventContainers(withEvent), listShowEmptyCalendars ? withoutEvent : [])
    }
}
