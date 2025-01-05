//
//  EventListHeader.swift
//  How Long Left
//
//  Created by Ryan on 26/11/2024.
//

import SwiftUI
import HowLongLeftKit

struct EventListHeader: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var keyEvent: HLLEvent
    
    var geometry: GeometryProxy
    
    var collapseProgress: CGFloat
    
    var backgroundColor: Color
    
    let gen = EventCountdownTextGenerator(showContext: false, postional: true)

    func getTimerTint(event: HLLEvent) -> Color {
        colorScheme == .light ? .white : event.color
    }

    
  
    
    var body: some View {
        TimelineView(.periodic(from: Date.previousSecondWithMillisecondZero, by: 1)) { context in
            
            ZStack {
                
                Rectangle().fill(backgroundColor.gradient)
               
                HStack(alignment: .center) {
                    
                    VStack {
                        
                        VStack(spacing: 40) {
                            VStack(spacing: 5) {
                                Text(keyEvent.title)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                
                                Text("\(keyEvent.status() == .upcoming ? "Starts" : "Ends") in ")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }
                            
                            let timerColor = getTimerTint(event: keyEvent)
                            
                            ProgressCircle(progress: keyEvent.completion(), lineWidth: 8, trackColor: timerColor.opacity(0.3), progressColor: timerColor, isRounded: true, progressType: .deplete, content: {
                                Text(gen.getString(from: keyEvent, at: Date()))
                                    .font(.system(size: 44, weight: .semibold, design: .default))
                                    .foregroundStyle(.white)
                                    .monospacedDigit()
                                    .lineLimit(1)
                                    .padding(.horizontal, 28)
                                    .minimumScaleFactor(0.5)
                            })
                            .frame(height: 190)
                            .padding(.horizontal, 32)
                        }
                        //.background(.red)
                        
                        
                        
                        //.padding(.bottom, geometry.safeAreaInsets.top)
                        .padding(.horizontal, 16)
                        .scaleEffect(1.0 - (0.3 * collapseProgress))
                        .opacity(1.0 - min(collapseProgress * 1.5, 1.0))
                    }
                    .padding(.top, geometry.safeAreaInsets.top/2)
                    
                    
                }
                
            }
            
            .shadow(radius: 6)
            .drawingGroup()
            
        }
    }
}

#Preview {
    
    VStack {
        GeometryReader { geometry in
            EventListHeader(keyEvent: HLLEvent.init(title: "Event", start: Date(), end: .now.addingTimeInterval(10000)), geometry: geometry, collapseProgress: 0, backgroundColor: .blue)
        }
    }
    
}
