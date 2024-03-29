//
//  DummyEventGenerator.swift
//  iOS How Long Left
//
//  Created by Ryan Kontos on 4/12/21.
//  Copyright © 2021 Ryan Kontos. All rights reserved.
//

import Foundation

class DummyEventGenerator {
    
    var events = [HLLEvent]()
    let amount = 50
    
    init() {
        

        
        if !ProcessInfo.processInfo.arguments.contains("EnableDummyEvents") {
            return
        }
        

        var start = Date()
        
        var array = [HLLEvent]()
        var date = start
        
        array.append(HLLEvent(title: "Current 1", start: start, end: start.addingTimeInterval(30), location: nil))
        array.append(HLLEvent(title: "Current 2", start: start, end: start.addingTimeInterval(100), location: nil))
        
        for i in 1...amount {
            
            date.addTimeInterval(30*300)
            var event = HLLEvent(title: "Test Event", start: start, end: date, location: nil)
            event.calendarID = CalendarReader.shared.getCalendars().randomElement()?.calendarIdentifier
            
            event.location = "Room: 23"
            
            array.append(event)
            
            start.addTimeInterval(60*120)
            
        }
        
       
        
       /* for i in 1...amount {
            
            
           
            var event = HLLEvent(title: "Upcoming \(i)", start: upcomingStart, end: upcomingStart.addingTimeInterval(60*30), location: nil)
            event.associatedCalendar = HLLEventSource.shared.getCalendars().randomElement()
            array.append(event)
            upcomingStart.addTimeInterval(60*60)
            
        } */
        
        events = array
        
    }
    
    
}
