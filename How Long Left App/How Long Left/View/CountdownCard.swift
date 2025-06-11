//
//  CountdownCard.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI
import HowLongLeftKit

struct CountdownCard: View {
    @ObservedObject var event: HLLEvent
    
    var body: some View {
        
        
        
        HStack(spacing: 12) {
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 6)
                    .foregroundStyle(event.color)
                    
                
                VStack(alignment: .leading, spacing: 10) {
                   
                    
                    
                    VStack(alignment: .leading, spacing: 7) {
                        title
                        timeLabel
                            .foregroundStyle(.secondary)
                    }
                        
                }
                Spacer(minLength: 12)
                
                CountdownRing(startDate: event.startDate, endDate: event.endDate, color: event.color, lineWidth: 6, content: {
                    return EventInfoText(
                        event,
                        stringGenerator: EventCountdownTextGenerator(
                            showContext: false,
                            postional:   true,
                            mode:        .remaining)
                        )
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .monospacedDigit()
                    .padding(.horizontal, 4)
                })
                
               
                .frame(width: 75, height: 75)
            }
            
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.vertical, 20)
            .drawingGroup()
            .glassCardBackground()
            
        
    }
   
    private var title: some View {
        Text(event.title)
            .font(.system(size: 19, weight: .bold))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
    }
    private var timeLabel: some View {
        let df = DateFormatter()
        df.locale = .autoupdatingCurrent
        if Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate),
           Calendar.current.isDateInToday(event.startDate) {
            df.dateFormat = "h:mm a"
            return Text("\(df.string(from: event.startDate)) – \(df.string(from: event.endDate))")
                .font(.system(size: 14.5, weight: .medium))
        } else {
            df.dateFormat = "d MMM, h:mm a"
            return Text("\(df.string(from: event.startDate)) – \(df.string(from: event.endDate))")
                .font(.system(size: 14.5, weight: .medium))
        }
    }
}

#Preview {
    CountdownCard(event: .init(title: "Anniversary Dinner",
                               startDate: Date().addingTimeInterval(-1000),
                               endDate:  Date().addingTimeInterval(999909), isAllDay: false,
                              
                               color: .yellow))
    .frame(width: 380, height: 120)
}
