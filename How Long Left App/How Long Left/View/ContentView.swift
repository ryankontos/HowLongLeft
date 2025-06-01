//
//  ContentView.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI
import HowLongLeftKit

struct ContentView: View {
    
    @EnvironmentObject var pointStore: TimePointStore
    
    
    var body: some View {
        
        
        TabView(content: {
            
            CountdownListContainer()
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
       
        
        
    }
}


#Preview {
    ContentView()
}
