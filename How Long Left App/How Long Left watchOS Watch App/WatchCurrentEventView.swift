//
//  WatchCurrentEventView.swift
//  How Long Left watchOS Watch App
//
//  Created by Ryan on 6/6/2025.
//

import SwiftUI
import HowLongLeftKit

struct WatchCurrentEventView: View {
    
    @ObservedObject var event: HLLEvent
    
    
    var body: some View {
        
  
        
            
            VStack(spacing: 25) {
                
                Spacer()
                
                
                CountdownRing(startDate: Date()-100, endDate: Date()+200, color: event.color, lineWidth: 5, content: {
                    
                    Text("00:00")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary.opacity(0.8))
                    
                })
               
                .frame(width: 120)
                
                VStack(spacing: 5) {
                    
                    Text(event.title)
                        .font(.system(size: 15, weight: .semibold, design: .default))
                    
                    
                    Text("9:00 AM - 10:00 AM")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundStyle(.secondary)
                    
                        
                        
                    
                }
                
                Spacer()
                
            }
            .background(Color.black)
          
            .edgesIgnoringSafeArea(.all)
            
        
    }
}

#Preview {
    WatchCurrentEventView(event: .example)
}
