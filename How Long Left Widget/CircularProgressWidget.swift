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
    var event: Event
    
    var body: some View {
        
        VStack {
            ProgressCircle(progress: 0.27, lineWidth: 10, trackColor: .gray.opacity(0.3), progressColor: .green, isRounded: true, size: 121, content: {
               
               VStack(spacing: 2) {
                   
                   Text("Event")
                       .lineLimit(1)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                   
                   Text(.now, format: .timer(countingDownIn: event.startDate..<event.endDate, showsHours: false, maxFieldCount: 3))
                       .font(.system(size: 25, weight: .semibold, design: .rounded))
                       .lineLimit(1)
                   
                   Text("remaining")
                       .font(.system(size: 12, weight: .semibold, design: .rounded))
                       .lineLimit(1)
                   
                       .foregroundColor(.secondary)
                   
               }
         
                    
            })
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// Preview with small widget context

#if os(iOS)

struct CircularProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        CircularProgressWidget(displayDate: Date(), event: .example)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

#endif
