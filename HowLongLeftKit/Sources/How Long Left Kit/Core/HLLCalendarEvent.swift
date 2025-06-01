//
//  HLLCalendarEvent.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
import EventKit

#if canImport(SwiftUI)
import SwiftUI
#endif

public class HLLCalendarEvent: HLLEvent {
    
    @Published public var calendar: HLLCalendar
    @Published public var structuredLocation: EKStructuredLocation?
    @Published internal(set) public var isPinned: Bool = false
    
    public var calendarID: String {
        return calendar.calendarIdentifier
    }
    
    public var location: CLLocation? {
        return structuredLocation?.geoLocation
    }
    
    
    public init(event: EKEvent) {
        let hllCalendar = HLLCalendar(ekCalendar: event.calendar)
        self.calendar = hllCalendar
        self.structuredLocation = event.structuredLocation
        self.isPinned = false
       
        super.init(
            title: event.title.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            eventIdentifier: event.eventIdentifier,
            color: hllCalendar.color
        )
    }
    
    public init(title: String, start: Date, end: Date, location: String? = nil, isAllDay: Bool = false, calendar: HLLCalendar) {
        self.calendar = calendar
        self.structuredLocation = nil
        self.isPinned = false
       
        super.init(title: title, startDate: start, endDate: end, isAllDay: isAllDay, eventIdentifier: UUID().uuidString, color: calendar.color)
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: HLLCalendarEvent, rhs: HLLCalendarEvent) -> Bool {
        return lhs.id == rhs.id && lhs.calendarID == rhs.calendarID
    }
    
    override public var id: String {
        return super.id + "-" + calendarID
    }
        

  
}
