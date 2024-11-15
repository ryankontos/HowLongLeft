//
//  EventWindowView.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/11/2024.
//

import SwiftUI
import HowLongLeftKit

struct EventWindowView: View {
    
    @EnvironmentObject var eventWindow: EventWindow
    
    var event: Event
    
    var calendarSource: CalendarSource
    
    var body: some View {
        
        CircularCountdownView(eventName: event.title, color: calendarSource.getColor(calendarID: event.calendarID), targetDate: event.endDate)
      
    }
}
/*
#Preview {
    EventWindowView(event: .init(title: "Event", start: .now, end: .now+120), calendarSource: <#CalendarSource#>)
}
*/
