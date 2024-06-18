//
//  EventMenuListItem.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/5/2024.
//

import SwiftUI
import HowLongLeftKit
import FluidMenuBarExtra

struct EventMenuListItem: View {
    
    @State var expand = false
    
    var mainMenuModel: WindowSelectionManager?
    
    @EnvironmentObject var source: CalendarSource
    
    @ObservedObject var progressManager: EventProgressManager
    
    var event: Event
    
    init(event: Event) {
        
        self.event = event
       
        self.progressManager = EventProgressManager(event: event)
        self.infoStringGen = InfoStringManager(event: event, stringGenerator: EventCountdownTextGenerator())
        
    }
    
    @ObservedObject var infoStringGen: InfoStringManager
    func getColor() -> Color {
        
        if let cg = source.lookupCalendar(withID: event.calId)?.cgColor {
            return Color(cg)
        }
        
        return .white
        
    }
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 8) {
            
                if !event.isAllDay {
                    
                    Circle()
                        .frame(width: 8)
                        .foregroundStyle(getColor().opacity(0.7))
                    
                } else {
                    
                    
                    
                }
              
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(event.title)")
                            .truncationMode(.middle)
                            .lineLimit(1)
                          
                        
                        if event.status() == .inProgress {
                            
                            Text(infoStringGen.infoString)
                                .monospacedDigit()
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                        }
                    }
                    .lineLimit(1)
                    
            
                Spacer()
                
                if event.status() == .inProgress {
                    
                    ProgressRingView(progress: progressManager.progress, ringWidth: 4, ringSize: 28, color: getColor())
                } else {
                    Text(formatTime(event: event))
                        .foregroundStyle(.secondary)
                        .font(.system(size: 10.5, weight: .regular))
                }
                
            }
            
            if expand {
                
                VStack {
                    
                    Text("Start and end")
                    
                }
                .padding(.vertical, 10)
                
            }
            
            
        }
       
       
    }
    
    func formatTime(event: Event) -> String {
        
        if event.isAllDay {
            return "all-day"
        }
        
        let date = event.startDate
        
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: date)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = minute == 0 ? "h a" : "h:mm a"
        
        // Check if the AM/PM setting is needed by the current locale
        if !dateFormatter.dateFormat.contains("a") {
            dateFormatter.dateFormat = minute == 0 ? "H" : "H:mm"
        }

        return dateFormatter.string(from: date)
    }
}
/*
#Preview {
    EventMenuListItem(mainMenuModel: nil, event: Event.init(title: "Event", start: Date(), end: Date().addingTimeInterval(1000)), infoStringGen: (event: , stringGenerator: )
    )
}
*/

