//
//  How_Long_LeftApp.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import SwiftUI
import HowLongLeftKit


@main
struct How_Long_LeftApp: App {
    
    let container = DefaultContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container.calendarReader)
                .environmentObject(container.calendarPrefsManager)
                .environmentObject(container.eventCache)
                .environmentObject(container.pointStore)
        }
        
    }
}


