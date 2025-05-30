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
   
    @Environment(\.scenePhase) var scenePhase

    

    let container = HLLCoreServicesContainer(id: "iOSApp")
    let widgetUpdateManager: WidgetUpdateManager

    init() {
        widgetUpdateManager = WidgetUpdateManager(appEventCache: container.eventCache)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container.calendarReader)
                .environmentObject(container.calendarPrefsManager)
                .environmentObject(container.eventCache)
                .environmentObject(container.pointStore)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        // //print("Active")

                        Task {
                            await widgetUpdateManager.checkIfWidgetNeedsReload()
                        }
                    } else if newPhase == .inactive {
                        // //print("Inactive")
                    } else if newPhase == .background {
                        // //print("Background")
                    }
                }
        }
    }
    
}
