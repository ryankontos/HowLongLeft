//
//  EventMenuListItem.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct EventMenuListItem: View {
    
    @State var expand = false
    
    var mainMenuModel: MainMenuViewModel?
    
    @EnvironmentObject var source: CalendarSource
    
    var event: Event
    
 
    func getColor() -> Color {
        
        if let cg = source.lookupCalendar(withID: event.calId)?.cgColor {
            return Color(cg)
        }
        
        return .white
        
    }
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 8) {
            
                Circle()
                    .frame(width: 8)
                    .foregroundStyle(getColor().opacity(0.7))
              
                    VStack(alignment: .leading, spacing: 1) {
                        Text("\(event.title)")
                            .truncationMode(.middle)
                            .lineLimit(1)
                          
                        
                        if event.status() == .inProgress {
                            
                            Text("Ends in 10 minutes")
                                .foregroundStyle(.secondary)
                            
                        }
                    }
                    .lineLimit(1)
                    
            
                Spacer()
                
                if event.status() == .inProgress {
                    
                    ProgressRingView(progress: 0.6, ringWidth: 4, ringSize: 19, color: getColor())
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

#Preview {
    EventMenuListItem(mainMenuModel: nil, event: .init(title: "Event", start: Date(), end: Date().addingTimeInterval(1000)))
}

struct ProgressRingView: View {
    var progress: Double // Progress should be a value between 0 and 1
    var ringWidth: CGFloat
    var ringSize: CGFloat
    var color: Color
    var body: some View {
        ZStack {
            Circle() // Background circle
                .stroke(lineWidth: ringWidth)
                .opacity(0.3)
                .foregroundColor(Color.gray)

            Circle() // Foreground circle showing progress
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(color.opacity(0.7))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
        .frame(width: ringSize, height: ringSize)
    }
}
