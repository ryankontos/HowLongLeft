//
//  TimePointStore.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
import Combine
import os.log
import SwiftUI

@MainActor
public class TimePointStore: EventCacheObserver, TimePointProviding {
   
    private let pointGen = TimePointGenerator()
    private lazy var logger = Logger(subsystem: "HowLongLeftMac", category: "TimePointStore.\(self.eventCache.id)")
    private var updateTimer: Timer?

    @Published public var points: [TimePoint] = []

    /// The current time point for `Date()`
    public var currentPoint: TimePoint? {
        getPointAt(date: Date())
    }
    
    public func isReady() -> Bool {
        return eventCache.isReady()
    }
    

    /// Initialize with a CompositeEventCache
    public override init(eventCache: CompositeEventCache) {
        super.init(eventCache: eventCache)
        Task {
            await updatePoints()
        }
    }

    /// Returns the last point whose date is <= the given date
    public func getPointAt(date: Date) -> TimePoint? {
        return points.last(where: { $0.date <= date }) ?? points.first
    }

    /// Generates and merges new time points from the cache
    private func updatePoints() async {
        let events = await eventCache.getEvents()
        let newPoints = pointGen.generateTimePoints(for: events, withCacheSummaryHash: eventCache.cacheSummaryHash)
        let foundChanges = mergePoints(newPoints)

        if foundChanges {
            scheduleNextUpdate()
        }
    }

    /// Merges incoming points with existing ones, animating changes
    private func mergePoints(_ newPoints: [TimePoint]) -> Bool {
        var updatedPoints = [TimePoint]()
        var changesDetected = false

        for newPoint in newPoints {
            if let existingPoint = points.first(where: { $0.date == newPoint.date }) {
                if existingPoint.updateInfo(from: newPoint) {
                    changesDetected = true
                }
                updatedPoints.append(existingPoint)
            } else {
                updatedPoints.append(newPoint)
                changesDetected = true
            }
        }

        updatedPoints.sort { $0.date < $1.date }

        if updatedPoints != points {
            print("Updating points from \(points.count) to \(updatedPoints.count)")
            if points.isEmpty {
                points = updatedPoints
            } else {
                withAnimation {
                    points = updatedPoints
                }
            }
            changesDetected = true
        }

        return changesDetected
    }

    /// Schedules a timer to update at the next point's date
    private func scheduleNextUpdate() {
        updateTimer?.invalidate()

        guard let next = points.first(where: { $0.date > Date() })?.date else { return }
        let interval = next.timeIntervalSinceNow
        guard interval > 0 else { return }

        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { await self?.updatePoints() }
        }
        if let timer = updateTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    /// Conform to TimePointProviding: trigger a refresh when events change
    public override func eventsChanged() async {
        await updatePoints()
    }
}
