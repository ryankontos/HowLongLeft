//
//  How_Long_Left_watchOSApp.swift
//  How Long Left watchOS Watch App
//
//  Created by Ryan on 24/9/2024.
//

import HowLongLeftKit
import SwiftUI

@main
struct How_Long_Left_watchOS_Watch_AppApp: App {
    let container = HLLCoreServicesContainer(id: "WatchApp")

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
