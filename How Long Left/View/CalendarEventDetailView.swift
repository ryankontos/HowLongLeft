//
//  CalendarEventDetailView.swift
//  How Long Left
//
//  Created by Ryan on 13/1/2025.
//

import SwiftUI
import HowLongLeftKit

struct EventDetailView: View {
    
    var event: HLLEvent
    
    var body: some View {
        
        VStack {
            
            
            ProgressCircle(progress: 0.4, lineWidth: 11, progressColor: event.calendar.color, content: {
                
                EventInfoText(event, stringGenerator: EventCountdownTextGenerator(showContext: false, postional: true))
                    .font(.system(size: 55, weight: .medium, design: .default))
                    .opacity(0.6)
                    .monospacedDigit()
                
            })
            .padding(.horizontal, 60)
            
            
            Spacer()
            
        }
        .padding(.top, 50)
        .padding(.horizontal, 10)
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: .example)
    }
}
