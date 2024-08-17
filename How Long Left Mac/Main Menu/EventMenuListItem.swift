//
//  EventMenuListItem.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/5/2024.
//

import SwiftUI
import HowLongLeftKit
import FluidMenuBarExtra
import Defaults

struct EventMenuListItem: View {
    
    @Default(.showLocationsInMainMenu) var showLocations
    
    @State var expand = false
    
    var timerContainer: GlobalTimerContainer
    
    var mainMenuModel: WindowSelectionManager?
    
    @EnvironmentObject var source: CalendarSource
    
    @ObservedObject var progressManager: EventProgressManager
    
    var event: Event
    
    let dateFormatter = DateFormatterUtility()
    
    @ObservedObject var selectedManager: StoredEventManager
    
    var forceProminent: Bool
    
    init(event: Event, selectedManager: StoredEventManager, timerContainer: GlobalTimerContainer, forceProminent: Bool) {
        
        self.event = event
        self.selectedManager = selectedManager
        self.progressManager = EventProgressManager(event: event)
        self.timerContainer = timerContainer
        self.forceProminent = forceProminent
        
    }
    
    func getProminence() -> Bool {
        if forceProminent {
            return true
        }
        
        return event.status() != .upcoming
    }
    
    func getColor() -> Color {
        
        if let cg = source.lookupCalendar(withID: event.calendarID)?.cgColor {
            return Color(cg)
        }
        
        return .white
        
    }
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 8) {
            
                if selectedManager.isEventStored(event: event) {
                    Image(systemName: "checkmark")
                }
                
                if !getProminence() {
                    
                    Text(formatTime(event: event))
                        .foregroundStyle(.secondary)
                        .font(.system(size: 11.5, weight: .medium))
                        .frame(width: 55)
                        .lineLimit(1)
                    
                }
                
                if !event.isAllDay || getProminence() {
                    
                    Circle()
                        .frame(width: 8)
                        .foregroundStyle(getColor().opacity(0.7))
                    
                }
              
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(event.title)")
                            .truncationMode(.middle)
                            .lineLimit(1)
                          
                        
                     
                        
                        if let location = event.locationName, showLocations {
                            
                            HStack(spacing: 3) {
                                
                                Image(systemName: "location.fill")
                                
                                Text(location)
                                    
                                    .lineLimit(1)
                                   
                                
                            }
                            .foregroundStyle(.secondary)
                        }
                        
                        if getProminence() {
                            
                            EventCountdownText(event)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                        }
                        
                        
                    }
                    .lineLimit(1)
                    
            
                Spacer()
                
                if event.status() == .inProgress {
                    ProgressRingView(progress: progressManager.progress, ringWidth: 4, ringSize: 22, percentageRingWidth: 4, percentageRingSize: 26, color: getColor())
                }
                
            }
            
          
            
            
        }
       // .animation(.default)
       
       
    }
    
    func formatTime(event: Event) -> String {
        
        if event.isAllDay {
            return "all-day"
        }
        
        return dateFormatter.formattedTimeString(event.startDate)
    }
}
/*
#Preview {
    EventMenuListItem(mainMenuModel: nil, event: Event.init(title: "Event", start: Date(), end: Date().addingTimeInterval(1000)), infoStringGen: (event: , stringGenerator: )
    )
}
*/

