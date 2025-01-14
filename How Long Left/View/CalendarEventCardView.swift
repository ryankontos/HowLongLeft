//
//  CalendarEventCardView.swift
//  How Long Left
//
//  Created by Ryan on 14/1/2025.
//

import SwiftUI
import HowLongLeftKit

struct CalendarEventCardView: View {
    let container: CalendarEventContainer
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color(UIColor.secondarySystemBackground))
            
            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 7, height: 7)
                        .foregroundColor(Color(container.calendar.color))
                    Text(container.calendar.title)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .font(.system(size: 14, weight: .medium))
                
                Divider()
                    .frame(height: 1.3)
                    .background(Color.primary.opacity(0.2))
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(container.event?.title ?? "No Events")
                                .foregroundStyle(Color(UIColor.label))
                            if let event = container.event {
                                EventInfoText(
                                    event,
                                    stringGenerator: EventCountdownTextGenerator(
                                        showContext: true,
                                        postional: false
                                    )
                                )
                                .foregroundStyle(Color(container.calendar.color))
                            }
                        }
                        
                        if container.event != nil {
                            ProgressView(value: 0.5, total: 1.0)
                                .progressViewStyle(CalendarEventProgressStyle(container: container))
                                .frame(height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
                    .font(.system(size: 22, weight: .semibold))
                    
                    Spacer()
                }
                .padding(.top, 5)
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
        }
        .opacity(container.event != nil ? 1 : 0.4)
    }
}

struct CalendarEventProgressStyle: ProgressViewStyle {
    let container: CalendarEventContainer
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(UIColor.systemGray5))
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(container.calendar.color))
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 200)
        }
    }
}

#Preview {

    let mockEvent = HLLEvent.example
    
    let mockCalendar = HLLCalendar(calendarIdentifier: UUID().uuidString, title: "Cal", color: .pink)
    
    let mockContainer = CalendarEventContainer(
        calendar: mockCalendar, event: mockEvent
    )
    
    CalendarEventCardView(container: mockContainer)
        .frame(width: 400, height: 175)
        
}
