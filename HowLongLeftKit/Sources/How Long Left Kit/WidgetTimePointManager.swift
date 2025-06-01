//
//  WidgetTimePointManager.swift
//  How Long Left
//
//  Created by Ryan on 22/9/2024.
//

import Combine
import Foundation
import WidgetKit

@MainActor
public class WidgetTimePointManager {
    public let timePointStore: TimePointStore

    private let userDefaults = UserDefaults(suiteName: "group.ryankontos.howlongleft")!
    private let userDefaultsKey = "WidgetComputedHash"

    public init(eventCache: CompositeEventCache) {
        self.timePointStore = TimePointStore(eventCache: eventCache)
    }

    public func generateTimelineEntries(interval: TimeInterval = 60, enablePadding: Bool = true) -> [TimePointEntry] {
        let currentDate = Date()
        var entries: [TimePointEntry] = []
        let upcomingPoints = timePointStore.points.filter { $0.date >= currentDate - 1 }
        
        // Add the current point if it exists
        if let currentPoint = timePointStore.currentPoint {
            let entry = TimePointEntry(date: currentDate, timePoint: currentPoint, configuration: HLLWidgetConfigurationIntent())
            entries.append(entry)
        }
        
        // Iterate through time points
        for (index, point) in upcomingPoints.enumerated() {
            // Add the entry for the actual time point
            let entry = TimePointEntry(date: point.date, timePoint: point, configuration: HLLWidgetConfigurationIntent())
            entries.append(entry)
            
            // Add padding entries if enabled
            if enablePadding && !point.inProgressEvents.isEmpty {
                var paddingDate = point.date
                while true {
                    paddingDate += interval
                    // Stop if the padding date exceeds the next time point's date
                    if index + 1 < upcomingPoints.count, paddingDate >= upcomingPoints[index + 1].date {
                        break
                    }
                    // Stop if paddingDate is beyond a reasonable future window (optional safeguard)
                    if paddingDate > currentDate.addingTimeInterval(24 * 60 * 60) {
                        break
                    }
                    let paddingEntry = TimePointEntry(date: paddingDate, timePoint: point, configuration: HLLWidgetConfigurationIntent())
                    entries.append(paddingEntry)
                }
            }
        }
        
        // Save the new cache hash
        if let newCacheHash = timePointStore.points.first?.cacheSummaryHash {
            saveCacheHash(newCacheHash)
        }
        return entries
    }


    private func saveCacheHash(_ hash: String) {
        userDefaults.set(hash, forKey: userDefaultsKey)
    }
}

public struct TimePointEntry: TimelineEntry {
    
    public init(date: Date, timePoint: TimePoint, configuration: HLLWidgetConfigurationIntent) {
        self.date = date
        self.timePoint = timePoint
        self.configuration = configuration
    }
    
    public let date: Date
    public let timePoint: TimePoint
    public let configuration: HLLWidgetConfigurationIntent
}
