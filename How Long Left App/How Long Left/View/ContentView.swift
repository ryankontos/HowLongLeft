//
//  ContentView.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI
import HowLongLeftKit

struct ContentView: View {
    
    @EnvironmentObject var pointStore: TimePointProviderWrapper
    
    @EnvironmentObject var calendarSource: CalendarSource
    
    var body: some View {
        
        
        TabView(content: {
            
            MainView()
                .toolbarBackground(.visible, for: .tabBar)
                .tabItem {
                    Label("Countdowns", systemImage: "timer")
                }
            
            SettingsView()
                .toolbarBackground(.visible, for: .tabBar)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            
        })
        .sheet(isPresented: $calendarSource.calendarAccessDenied) {
            
            NoCalendarAccessView()
                .interactiveDismissDisabled()
                
            
        }
       
        
        
    }
}


#Preview {
    ContentView()
        .environmentObject(TimePointProviderWrapper.dummy(empty: false))
        .environmentObject(CalendarSource(requestCalendarAccessImmediately: true))
        
}
