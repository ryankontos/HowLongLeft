//
//  CountdownCard.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI
import HowLongLeftKit

struct CountdownCard: View {
    let event: HLLEventViewModel
    
    var body: some View {
        
            let remaining = max(event.endDate.timeIntervalSince(Date()), 0)
            let progress  = 1 - remaining / event.endDate.timeIntervalSince(event.startDate)
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    pill
                    VStack(alignment: .leading, spacing: 7) {
                        title
                        timeLabel
                            .foregroundStyle(.secondary)
                    }
                        
                }
                Spacer(minLength: 12)
                
                CountdownRing(startDate: event.startDate, endDate: event.endDate, color: event.color, lineWidth: 6, fontSize: 15, fontWeight: .semibold)
                
               
                .frame(width: 75, height: 75)
            }
            .padding(20)
            .glassCardBackground()
        
    }
    
    private var pill: some View {
        Text(event.calendarName)
            .font(.system(size: 14.5).weight(.semibold))
            .padding(.vertical, 3)
            .padding(.horizontal, 9)
            .shadow(radius: 2)
            .background(Capsule().fill(event.color))
            .foregroundStyle(.white.opacity(0.9))
            
    }
    private var title: some View {
        Text(event.title)
            .font(.system(size: 23, weight: .bold))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
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
                               start: Calendar.current.date(from: .init(year: 2025, month: 4, day: 24, hour: 19))!,
                               end:   Calendar.current.date(from: .init(year: 2025, month: 4, day: 24, hour: 22))!,
                               calendar: "Friends",
                               color: .yellow))
}
