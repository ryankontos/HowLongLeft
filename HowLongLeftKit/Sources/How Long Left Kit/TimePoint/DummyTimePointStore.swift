//
//  DummyTimePointStore.swift
//  HowLongLeftKit
//
//  Created by Ryan on 6/6/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
public class DummyTimePointStore: TimePointProviding {
    public func isReady() -> Bool {
        return true
    }
    
    @Published public var points: [TimePoint] = []

    /// The current time point for `Date()`
    public var currentPoint: TimePoint? {
        getPointAt(date: Date())
    }

    /// Sets up a fixed dummy time point
    public init(empty: Bool = false) {
        let now = Date()

        // All dummy events are in progress
        let inProgress = [
            HLLEvent.makeExampleEvent(
                title: "Live Coding Interview",
                start: now.addingTimeInterval(-1200), // 20m ago
                end: now.addingTimeInterval(1800),    // in 30m
                color: .blue
            ),
            HLLEvent.makeExampleEvent(
                title: "Team Stand-up Call",
                start: now.addingTimeInterval(-600),  // 10m ago
                end: now.addingTimeInterval(900),     // in 15m
                color: .green
            ),
            HLLEvent.makeExampleEvent(
                title: "Brunch & Brainstorm",
                start: now.addingTimeInterval(-1800), // 30m ago
                end: now.addingTimeInterval(3600),    // in 1h
                color: .orange
            ),
            HLLEvent.makeExampleEvent(
                title: "Study: UI Design Patterns",
                start: now.addingTimeInterval(-900),  // 15m ago
                end: now.addingTimeInterval(2700),    // in 45m
                color: .purple
            ),
            HLLEvent.makeExampleEvent(
                title: "Ambient Music Session",
                start: now.addingTimeInterval(-300),  // 5m ago
                end: now.addingTimeInterval(2400),    // in 40m
                color: .pink
            )
        ]

        let upcoming = [
            HLLEvent.makeExampleEvent(
                title: "Game Night Setup",
                start: now.addingTimeInterval(5400),
                end: now.addingTimeInterval(7200),
                color: .red
            )
        ]

        
        
        
        let dummyPoint = TimePoint(
            date: now,
            cacheSummaryHash: "five-in-progress-dummy",
            inProgressEvents: inProgress,
            upcomingEvents: upcoming
        )
        
        if empty {
            dummyPoint.inProgressEvents.removeAll()
            dummyPoint.upcomingEvents.removeAll()
        }

        self.points = [dummyPoint]
    }

    /// Returns the last point whose date is <= the given date
    public func getPointAt(date: Date) -> TimePoint? {
        return points.last(where: { $0.date <= date }) ?? points.first
    }

    /// No-op for dummy
    public func eventsChanged() async {
        // nothing to update
    }
}
