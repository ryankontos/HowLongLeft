//
//  How_Long_LeftApp.swift
//  How Long Left
//
//

import HowLongLeftKit
import SwiftUI
import WidgetKit

@main
struct How_Long_LeftApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let container = HLLCoreServicesContainer(id: "iOSApp")
    var widgetUpdateManager: WidgetUpdateManager

    init() {
        widgetUpdateManager = WidgetUpdateManager(appEventCache: container.eventCache)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container.calendarReader)
                .environmentObject(container.calendarPrefsManager)
                .environmentObject(container.eventCache)
                .environmentObject(TimePointProviderWrapper(provider: container.pointStore))
                .environmentObject(container.userEventSource)
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
                .onAppear() {
                    for family in UIFont.familyNames {
                        print(family)
                        for name in UIFont.fontNames(forFamilyName: family) {
                            print(" - \(name)")
                        }
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions
                        _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        //print("App has launched")
        return true
    }

    func applicationDidBecomeActive(_: UIApplication) {
    }
}
