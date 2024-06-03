//
//  EventList.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct EventList: View {
    
    @EnvironmentObject var pointStore: TimePointStore
    @EnvironmentObject var calendarSource: CalendarSource
    
    var body: some View {
        
        if let point = pointStore.getPointAt(date: Date()) {
            NavigationStack {
                getPointsList(from: point)
                    .navigationTitle("How Long Left")
            }
        } else {
            ProgressView()
        }
    }
    
    func getPointsList(from point: TimePoint) -> some View {
        
        List {
            
            
            Section("In-Progress") {
                
                ForEach(point.inProgressEvents) { event in
                   
                    EventCardView(eventName: event.title, endDate: event.endDate)
                    
                }
                
            }
            
            Section("Upcoming") {
                
                ForEach(point.upcomingEvents) { event in
                   
                    EventListItem(event: event)
                    
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    EventList()
}
