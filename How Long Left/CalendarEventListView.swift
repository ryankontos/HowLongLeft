//
//  CalendarEventListView.swift
//  How Long Left
//
//  Created by Ryan on 3/1/2025.
//

import SwiftUI
import HowLongLeftKit

struct CalendarEventListView: View {
    
    @ObservedObject var calendarEventListProvider: CalendarEventListProvider
    
    var body: some View {
        
        List {
            
            ForEach($calendarEventListProvider.eventList) { $container in
                
                Text("\(container.calendar.title): \(container.event?.title ?? "No Event")")
                
            }
            
        }
        
    }
}

#Preview {
    
    let defaultContainer = HLLCoreServicesContainer(id: "iOSApp")
    
    CalendarEventListView(calendarEventListProvider: .init(pointStore: defaultContainer.pointStore))
}
