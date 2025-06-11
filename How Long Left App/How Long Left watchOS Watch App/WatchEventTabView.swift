//
//  WatchEventTabView.swift
//  How Long Left watchOS Watch App
//
//  Created by Ryan on 6/6/2025.
//

import SwiftUI
import HowLongLeftKit

struct WatchEventTabView: View {
    
    @ObservedObject var event: HLLEvent
    
    
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            WatchCurrentEventView(event: event)
                .tag(0)
            
            Text("Info")
                .tag(1)
                .containerBackground(event.color.gradient,
                                     for: .tabView)
            
        }
        .onDisappear() {
            // Reset the tab when the view disappears
           // selectedTab = 0
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    WatchEventTabView(event: .makeExampleEvent(title: "Event Test", end: Date()+1000, color: .purple), selectedTab: .constant(0))
}
