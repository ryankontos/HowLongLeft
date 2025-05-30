//
//  CircularProgressWidget.swift
//  How Long Left
//
//  Created by Ryan on 21/11/2024.
//

import SwiftUI
import HowLongLeftKit
import WidgetKit

struct CircularProgressWidget: View {
    
    var displayDate: Date
    var event: HLLCalendarEvent
    
    var body: some View {
        VStack(spacing: 8) { // Reduced spacing
            
            // Event Title
            Text(event.title)
                .lineLimit(1)
                .font(.system(size: 14, weight: .semibold, design: .rounded)) // Smaller font
                .foregroundColor(.secondary)
                .truncationMode(.middle)
                .padding(.horizontal, 5)
            
            // Progress Circle
            ProgressCircle(
                progress: 0.27,
                lineWidth: 10,
                trackColor: .gray.opacity(0.3),
                progressColor: event.color,
                isRounded: true
            ) {
                VStack(alignment: .center, spacing: -2) { // Fine-tuned alignment
                    Text(event.endDate, style: .timer)
                        .minimumScaleFactor(0.7) // Allow shrinking for longer times
                        .monospacedDigit()
                        .font(.system(size: 25, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
            }
            
            // Remaining Label
            Text("remaining")
                .lineLimit(1)
                .font(.system(size: 14, weight: .medium, design: .rounded)) // Adjusted font weight
                .foregroundColor(.secondary)
                .truncationMode(.middle)
                .padding(.horizontal, 5)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}


