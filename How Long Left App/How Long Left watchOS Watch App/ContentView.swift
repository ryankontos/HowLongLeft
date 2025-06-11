//
//  ContentView.swift
//  How Long Left watchOS Watch App
//
//  Created by Ryan on 25/1/2025.
//

import SwiftUI
import HowLongLeftKit

struct ContentView: View {
    
    @EnvironmentObject var timePointStore: DummyTimePointStore
    
    @State var innerSelection = 0
    
    @State private var isPulsing = false
    
    var body: some View {
        
        if let currentEvents = timePointStore.currentPoint?.inProgressEvents, !currentEvents.isEmpty {
            
            TabView {
                
                ForEach(currentEvents) { event in
                    
                    
                    WatchEventTabView(event: event, selectedTab: $innerSelection)
                        .tag(event.id)
                    
                    
                }
            
        }
            
            
        } else {
            Text("No Current Events")
                .opacity(isPulsing ? 1 : 0.5)
                                .onAppear {
                                    withAnimation(
                                        Animation.easeInOut(duration: 2)
                                            .repeatForever(autoreverses: true)
                                    ) {
                                        isPulsing = true
                                    }
                                }
                
        }
        
            
            
     
    }
}

#Preview {
    
    let container = HLLCoreServicesContainer(id: "WatchApp")
    
    ContentView()
        .environmentObject(DummyTimePointStore())
}
