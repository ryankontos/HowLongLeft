//
//  File.swift
//  HowLongLeftKit
//
//  Created by Ryan on 7/1/2025.
//

import Foundation

public struct CalendarEventContainer: Identifiable {
    
    public init(calendar: HLLCalendar, event: HLLEvent? = nil) {
        self.calendar = calendar
        self.event = event
    }
    
    public var id: String {
        return calendar.calendarIdentifier + (event?.id ?? "")
    }
    
    public var calendar: HLLCalendar
    public var event: HLLEvent?
    
}
