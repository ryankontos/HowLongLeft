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
public class TimePointStore: EventCacheObserver, ObservableObject {
    
    private let pointGen = TimePointGenerator()
    private lazy var logger = Logger(subsystem: "HowLongLeftMac", category: "TimePointStore.\(self.eventCache.id)")
    private var updateTimer: Timer?
    
    @Published public var points: [TimePoint] = []
    
    public var currentPoint: TimePoint? {
        return getPointAt(date: Date())
    }
    
    override public init(eventCache: CompositeEventCache) {
        super.init(eventCache: eventCache)
        
        Task {
            await updatePoints()
        }
    }
    
    public func getPointAt(date: Date) -> TimePoint? {
        return points.last(where: { $0.date <= date }) ?? points.first
    }
    
    private func updatePoints() async {
        let events = await eventCache.getEvents()
        let newPoints = pointGen.generateTimePoints(for: events, withCacheSummaryHash: eventCache.cacheSummaryHash ?? "")
        
        let foundChanges = mergePoints(newPoints)
        
        if foundChanges {
            scheduleNextUpdate()
        }
    }
    
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

    private func scheduleNextUpdate() {
        updateTimer?.invalidate()

        guard let nextUpdateTime = points.first(where: { $0.date > Date() })?.date else { return }

        let timeInterval = nextUpdateTime.timeIntervalSinceNow
        guard timeInterval > 0 else { return }

        updateTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            Task {
                await self?.updatePoints()
            }
        }

        if let updateTimer = updateTimer {
            RunLoop.main.add(updateTimer, forMode: .common)
        }
    }
    
    public override func eventsChanged() async {
        await updatePoints()
    }
}
