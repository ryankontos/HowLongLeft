//
//  WidgetTimePointManager.swift
//  How Long Left
//
//  Created by Ryan on 22/9/2024.
//

import Combine
import Foundation
import HowLongLeftKit
import WidgetKit

@MainActor
class WidgetTimePointManager {
    let timePointStore: TimePointStore

    private let userDefaults = UserDefaults(suiteName: "group.ryankontos.howlongleft")!
    private let userDefaultsKey = "WidgetComputedHash"

    init(eventCache: EventCache) {
        self.timePointStore = TimePointStore(eventCache: eventCache)
    }

    func generateTimelineEntries() -> [TimePointEntry] {
        let currentDate = Date()
        var entries: [TimePointEntry] = []
        let upcomingPoints = timePointStore.points.filter { $0.date >= currentDate-1 }

        if let currentPoint = timePointStore.currentPoint {
            let entry = TimePointEntry(date: currentDate, timePoint: currentPoint, configuration: HLLWidgetConfigurationIntent())
            entries.append(entry)
        }

        for point in upcomingPoints {
            let entry = TimePointEntry(date: point.date, timePoint: point, configuration: HLLWidgetConfigurationIntent())
            entries.append(entry)
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

struct TimePointEntry: TimelineEntry {
    let date: Date
    let timePoint: TimePoint
    let configuration: HLLWidgetConfigurationIntent
}
