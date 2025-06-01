//
//  MockEventDataGenerator.swift
//  HowLongLeftKit
//
//  Created by Ryan on 7/1/2025.
//

import Foundation
import SwiftUI

public class MockEventDataGenerator {
    let calendars: [HLLCalendar]
    let events: [HLLCalendarEvent]
    let containers: [CalendarEventContainer]
    
    private static let calendarNames = [
        "Work", "Personal", "Fitness", "Family", "Hobbies", "Travel", "Finance", "Health"
    ]
    
    private static let eventTitles = [
        "Meeting", "Workout", "Dinner", "Conference Call", "Doctor Appointment",
        "Grocery Shopping", "Project Deadline", "Team Sync", "Flight", "Birthday Party",
        "Yoga Class", "Client Call", "Workshop", "Training Session", "Lunch"
    ]
    
    private static let systemColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink, .teal, .cyan
    ]
    
    public init(numberOfCalendars: Int = 6, eventsPerCalendar: Int = 4) {
        self.calendars = Self.generateCalendars(count: numberOfCalendars)
        self.events = Self.generateEvents(for: self.calendars, eventsPerCalendar: eventsPerCalendar)
        self.containers = Self.generateEventContainers(calendars: self.calendars, events: self.events)
    }
    
    private static func generateCalendars(count: Int) -> [HLLCalendar] {
        let names = Array(calendarNames.shuffled().prefix(count))
        return names.map { name in
            HLLCalendar(
                calendarIdentifier: UUID().uuidString,
                title: name,
                color: systemColors.randomElement() ?? .gray
            )
        }
    }
    
    private static func generateEvents(for calendars: [HLLCalendar], eventsPerCalendar: Int) -> [HLLCalendarEvent] {
        var events = [HLLCalendarEvent]()
        let calendarsWithEvents = calendars.shuffled().prefix(calendars.count / 2) // Half the calendars have events
        
        for calendar in calendarsWithEvents {
            for eventIndex in 1...eventsPerCalendar {
                let title = eventTitles.randomElement() ?? "Event"
                let startDate = Date().addingTimeInterval(Double(eventIndex * 3600)) // Start 1-hour increments
                let endDate = startDate.addingTimeInterval(1800) // 30 minutes duration
                events.append(
                    HLLCalendarEvent(
                        title: "\(title)",
                        start: startDate,
                        end: endDate,
                        calendar: calendar
                    )
                )
            }
        }
        return events
    }
    
    private static func generateEventContainers(calendars: [HLLCalendar], events: [HLLCalendarEvent]) -> [CalendarEventContainer] {
        var containers = [CalendarEventContainer]()
        for calendar in calendars {
            let calendarEvents = events.filter { $0.calendarID == calendar.calendarIdentifier }
            if calendarEvents.isEmpty {
                containers.append(CalendarEventContainer(calendar: calendar, event: nil))
            } else {
                for event in calendarEvents {
                    containers.append(CalendarEventContainer(calendar: calendar, event: event))
                }
            }
        }
        return containers
    }
    
    /// Function to get the first event (or no event) for each calendar
    public func getFirstEventFromEachCalendar() -> [CalendarEventContainer] {
        var calendarMap: [String: CalendarEventContainer] = [:]
        
        for container in containers {
            let calendarID = container.calendar.calendarIdentifier
            
            // Add the container if the calendar ID is not already in the map
            if calendarMap[calendarID] == nil {
                calendarMap[calendarID] = container
            }
        }
        
        return Array(calendarMap.values)
    }
}
