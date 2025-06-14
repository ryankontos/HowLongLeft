//
//  WidgetUpdateManager.swift
//  How Long Left
//
//  Created by Ryan on 23/9/2024.
//

import Combine
import Foundation
import WidgetKit
/*
@MainActor
class WidgetUpdateManager {
    private var eventCacheSubscription: AnyCancellable?
    private let defaults = UserDefaults(suiteName: "group.ryankontos.howlongleft")!
    private let widgetContainer: HLLCoreServicesContainer
    private let appEventCache: CalendarEventCache
    private let userDefaultsKey = "WidgetComputedHash"

    private var latestHashReloadedFor: String?


    init(appEventCache: CalendarEventCache) {
        self.appEventCache = appEventCache
        // Create the widgetContainer with the same configuration as the widget
        self.widgetContainer = HLLCoreServicesContainer(id: "iOSWidget")
        // Subscribe to the app's eventCache changes
        self.eventCacheSubscription = appEventCache.objectWillChange.sink { [weak self] _ in
            self?.eventCacheDidChange()
        }
    }

    private func eventCacheDidChange() {
        
            checkIfWidgetNeedsReload()
        
    }

    func checkIfWidgetNeedsReload() {
        // Wait until the eventCache has been updated
        let widgetEventCache = widgetContainer.eventCache
       
        // Get the new hash
        let newHash = widgetEventCache.cacheSummaryHash
        // Get the last known hash from UserDefaults
        let lastHash = defaults.string(forKey: userDefaultsKey)

        // //print("Last Hash: \(lastHash ?? "Nil")")
        // //print("New Hash: \(newHash ?? "Nil")")

        if newHash != lastHash {
            if let latestHashReloadedFor {
                if latestHashReloadedFor == newHash {
                    //print("Already reloaded for this hash, skipping")
                    return
                }
            }

            latestHashReloadedFor = newHash

            //print("Reloading Widget")

            // Hashes differ, trigger widget reload
            WidgetCenter.shared.reloadAllTimelines()
            // Update the stored hash
            // defaults.set(newHash, forKey: userDefaultsKey)
        }
    }
}
*/
