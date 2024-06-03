//
//  EventListItem.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import SwiftUI
import HowLongLeftKit
import EventKit

struct EventListItem: View {
    
    @ObservedObject var event: Event
    @EnvironmentObject var calendarSource: CalendarSource
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Circle()
                .foregroundStyle(getColor())
                .frame(width: 10)
                
            
            Text(event.title)
            
            Text("\(event.startDate.formatted()) - \(event.endDate.formatted())")
            
        }
    }
    
    func getColor() -> Color {
        
        if let col = calendarSource.lookupCalendar(withID: event.calId)?.cgColor {
            return Color(cgColor: col)
        }
        
        return .primary
            
        
        
    }
}

#Preview {
    EventListItem(event: Event(title: "Event", start: Date(), end: Date().addingTimeInterval(1000)))
}
