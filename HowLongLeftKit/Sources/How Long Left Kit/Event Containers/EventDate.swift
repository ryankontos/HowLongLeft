//
//  EventDate.swift
//  How Long Left Kit
//
//  Created by Ryan on 3/6/2024.
//

import Foundation

public class EventDate: Equatable {
    public static func == (lhs: EventDate, rhs: EventDate) -> Bool {
        return lhs.date == rhs.date && lhs.events == rhs.events
    }
    
    
    init(date: Date, events: [HLLEvent]) {
        self.date = date
        self.events = events
    }
    
    // Must be midnight/start of day
    public var date: Date
    
    // Events that occur on this day
    public var events: [HLLEvent]
    
}
