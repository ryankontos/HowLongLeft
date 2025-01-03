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
    
    private func getEventList() -> [CalendarEventContainer] {
        guard let calendars = pointStore.eventCache.getAllowedCalendars() else {
           return []
        }
        
        var returnArray: [CalendarEventContainer] = []
        
        let currentPoint = pointStore.currentPoint
        
        for calendar in calendars {
            if let event = currentPoint?.fetchSingleEvent(accordingTo: .preferInProgress, for: calendar.calendarIdentifier) {
                returnArray.append(CalendarEventContainer(calendar: calendar, event: event))
            } else {
                returnArray.append(CalendarEventContainer(calendar: calendar, event: nil))
            }
        }
        
        return returnArray
    }
}

public struct CalendarEventContainer: Identifiable {
    
    public var id: String {
        return calendar.calendarIdentifier + (event?.id ?? "")
    }
    
    public var calendar: EKCalendar
    public var event: Event?
    
}
