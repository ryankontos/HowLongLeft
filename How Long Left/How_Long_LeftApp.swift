//
//  How_Long_LeftApp.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import SwiftUI
import HowLongLeftKit
import WidgetKit

@main
struct How_Long_LeftApp: App {

    @Environment(\.scenePhase) var scenePhase

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
                                  // print("Active")

                                   Task {
                                     await widgetUpdateManager.checkIfWidgetNeedsReload()
                                   }

                               } else if newPhase == .inactive {
                                  // print("Inactive")
                               } else if newPhase == .background {
                                  // print("Background")
                               }
                           }

        }

    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("App has launched")
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

}
