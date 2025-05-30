//
//  WatchEventListView.swift
//  How Long Left watchOS Watch App
//
//  Created by Ryan on 25/1/2025.
//

import SwiftUI
import HowLongLeftKit

struct WatchEventListView: View {
    
    @ObservedObject var calendarEventListProvider: CalendarEventListProvider
    
    var body: some View {
        List {
            
            ForEach(calendarEventListProvider.containersWithEvent) { container in
                
                HStack(spacing: 12) {
                    
                    ProgressCircle(progress: 0.2, lineWidth: 5, progressColor: container.calendar.color, isRounded: true, progressType: .fill, content: {})
                        .frame(width: 30)
                  
                    VStack(alignment: .leading, spacing: 3) {
                        
                        Text(container.event?.title ?? "No event")
                            .font(.system(size: 17, weight: .medium))
                            .lineLimit(2)
                        
                        Text("10 mins left")
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        
                    }
                    .padding(.vertical, 1)
                    
                    Spacer()
                    
                   
                    
                   
                    
                }
                .padding(.leading, 3)
                .padding(.vertical, 9)
               
                
            }
            
          
            
        }
       
        .listStyle(.elliptical)
        .navigationTitle("In-Progress")
    }
}

#Preview {
    NavigationStack {
        let defaultContainer = HLLCoreServicesContainer(id: "WatchApp")
        WatchEventListView(calendarEventListProvider: MockCalendarEventListProvider(timePointStore: defaultContainer.pointStore))
            .environmentObject(defaultContainer.calendarPrefsManager)
    }
}
