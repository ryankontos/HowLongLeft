//
//  ContentView.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            EventList()
                .tabItem {
                    Label("Events", systemImage: "list.bullet")
                }

            EnabledCalendarsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
