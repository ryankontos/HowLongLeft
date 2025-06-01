//
//  TimePoint.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
import AppIntents

@MainActor
public class TimePoint: @preconcurrency Equatable, ObservableObject, @preconcurrency Identifiable {
    
    public var date: Date
    
    public var cacheSummaryHash: String
    
    @Published public var inProgressEvents: [HLLEvent]
    @Published public var upcomingEvents: [HLLEvent]
    
    public var allEvents: [HLLEvent] {
        return inProgressEvents + upcomingEvents
    }
    
    public var id: Date { return date }
    
    public init(date: Date, cacheSummaryHash: String, inProgressEvents: [HLLEvent], upcomingEvents: [HLLEvent]) {
        self.date = date
        self.cacheSummaryHash = cacheSummaryHash
        self.inProgressEvents = inProgressEvents.filter { $0.status(at: date) == .inProgress }
        self.upcomingEvents = upcomingEvents.filter { $0.status(at: date) == .upcoming }

        // Check that inProgressEvents only contain in-progress events
        for event in self.inProgressEvents {
            if event.status(at: date) != .inProgress {
                fatalError("Event \(event.title) is not in progress at \(date)")
            }
        }

        // Check that upcomingEvents only contain upcoming events
        for event in self.upcomingEvents {
            if event.status(at: date) != .upcoming {
                fatalError("Event \(event.title) is not upcoming at \(date)")
            }
        }
        
    }
    
    public static func == (lhs: TimePoint, rhs: TimePoint) -> Bool {
        return lhs.date == rhs.date && lhs.inProgressEvents.infoHash() == rhs.inProgressEvents.infoHash() && lhs.upcomingEvents.infoHash() == rhs.upcomingEvents.infoHash()
    }
    
    public func fetchSingleEvent(accordingTo rule: EventFetchRule, for calendarID: String? = nil) -> HLLEvent? {
        // Use the new fetchEvents method to get the filtered and sorted array of events
        let filteredEvents = fetchEvents(accordingTo: rule, for: calendarID)
        
        // Return the first event in the filtered list, or nil if the list is empty
        return filteredEvents.first
    }
    
    public func fetchEvents(accordingTo rule: EventFetchRule, for calendarID: String? = nil) -> [HLLEvent] {
        var filteredEvents: [HLLEvent]
        
        switch rule {
        case .upcomingOnly:
            var eventsToFilter: [HLLEvent] = upcomingEvents
            
            if let calendarID {
                eventsToFilter = eventsToFilter.filter {
                    if let event = $0 as? HLLCalendarEvent {
                        return event.calendarID == calendarID
                    } else {
                        return false
                    }
                }
                    
            }
            
            filteredEvents = eventsToFilter.sortedByStartDate() // Only upcoming events, sorted by start date
            
        case .inProgressOnly:
            var eventsToFilter: [HLLEvent] = inProgressEvents
            
            if let calendarID {
                eventsToFilter = eventsToFilter.onlyCalendarEvents().filter { $0.calendarID == calendarID }
            }
            
            filteredEvents = eventsToFilter.sortedByStartDate() // Only in-progress events, sorted by start date
            
        case .preferUpcoming:
            var upcomingToFilter: [HLLEvent] = upcomingEvents
            var inProgressToFilter: [HLLEvent] = inProgressEvents
            
            if let calendarID {
                upcomingToFilter = upcomingToFilter.onlyCalendarEvents().filter { $0.calendarID == calendarID }
                inProgressToFilter = inProgressToFilter.onlyCalendarEvents().filter { $0.calendarID == calendarID }
            }
            
            filteredEvents = upcomingToFilter.sortedByStartDate() + inProgressToFilter.sortedByStartDate()
            
        case .preferInProgress:
            var inProgressToFilter: [HLLEvent] = inProgressEvents
            var upcomingToFilter: [HLLEvent] = upcomingEvents
            
            if let calendarID {
                inProgressToFilter = inProgressToFilter.onlyCalendarEvents().filter { $0.calendarID == calendarID }
                upcomingToFilter = upcomingToFilter.onlyCalendarEvents().filter { $0.calendarID == calendarID }
            }
            
            filteredEvents = inProgressToFilter.sortedByStartDate() + upcomingToFilter.sortedByStartDate()
            
        case .soonestCountdownDate:
            var allToFilter: [HLLEvent] = allEvents
            
            if let calendarID {
                allToFilter = allToFilter.onlyCalendarEvents().filter { $0.calendarID == calendarID }
            }
            
            filteredEvents = allToFilter.sorted {
                $0.countdownDate(at: date) < $1.countdownDate(at: date)
            }
            
        case .noEvents:
            filteredEvents = []
        }
        
        return filteredEvents
    }
    
    func updateInfo(from new: TimePoint) -> Bool {
        var flag = false
        updateIfNeeded(&self.inProgressEvents, compareTo: new.inProgressEvents, flag: &flag)
        updateIfNeeded(&self.upcomingEvents, compareTo: new.upcomingEvents, flag: &flag)
        
        return flag
    }
    
    public static func makeEmpty() -> TimePoint {
        return TimePoint(date: Date(), cacheSummaryHash: "", inProgressEvents: [], upcomingEvents: [])
    }
        

}

public enum EventFetchRule: Int, CaseIterable {
    
    case noEvents
    case upcomingOnly
    case inProgressOnly
    case preferUpcoming
    case preferInProgress
    case soonestCountdownDate
    
}

