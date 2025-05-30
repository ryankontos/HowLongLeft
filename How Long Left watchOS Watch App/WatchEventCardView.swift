//
//  WatchEventCardView.swift
//  How Long Left watchOS Watch App
//
//  Created by Ryan on 25/1/2025.
//

import SwiftUI
import HowLongLeftKit

struct WatchEventCardView: View {
    
    var event: HLLCalendarEvent
    
    var displayMode: DisplayMode = .rightProgressCircle
    
    enum DisplayMode {
        case noProgress
        case leftProgressCircle
        case rightProgressCircle
        case progressBar
    }
    
    var body: some View {
        HStack(spacing: 12) {
            
            if displayMode == .leftProgressCircle {
                
                ProgressCircle(progress: 0.2, lineWidth: 5, progressColor: .blue, isRounded: true, progressType: .fill, content: {})
                    .frame(width: 28)
                
            }
            
            VStack(alignment: .leading, spacing: 3) {
                
                Text(event.title)
                    .font(.system(size: 17, weight: .medium))
                
                Text("10 mins left")
                    .foregroundStyle(.secondary)
                
            }
            .padding(.vertical, 4)
            
            
            Spacer()
            
            if displayMode == .rightProgressCircle {
                ProgressCircle(progress: 0.2, lineWidth: 5, progressColor: .blue, isRounded: true, progressType: .fill, content: {})
                    .frame(width: 28)
            }
          
            
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    List {
        WatchEventCardView(event: .example)
    }
}
