//
//  TimePointGenerator.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import Foundation

@MainActor
class TimePointGenerator {
    
    private var earliestTime: Date

    init() {
        self.earliestTime = Date()
    }

    func generateFirstPoint(for events: [HLLEvent], withCacheSummaryHash hash: String) -> TimePoint {
        return generateTimePoint(for: Date(), from: events, withCacheSummaryHash: hash)
    }

    func generateTimePoints(for events: [HLLEvent], withCacheSummaryHash hash: String) -> [TimePoint] {
        let now = Date()
        
        if now.timeIntervalSince(earliestTime) > 3 {
            earliestTime = now
        }
        
        var timePoints = [TimePoint]()
        var dates = [earliestTime]
        dates.append(contentsOf: events.flatMap { [$0.startDate, $0.endDate] }.sorted())

        for (index, date) in dates.enumerated() {
            if index == 0 || date >= now {
                timePoints.append(generateTimePoint(for: date, from: events, withCacheSummaryHash: hash))
            }
        }
        
        timePoints.sort { $0.date < $1.date }
        
        return timePoints
    }

    func generateTimePoint(for date: Date, from events: [HLLEvent], withCacheSummaryHash hash: String) -> TimePoint {
        var currentArray = [HLLEvent]()
        var upcomingArray = [HLLEvent]()
        
        for event in events {
            if event.status(at: date) == .inProgress {
               
                currentArray.append(event)
            } else if event.status(at: date) == .upcoming {
                upcomingArray.append(event)
            }
        }
        
        currentArray = currentArray.sortedByEndDate()
        upcomingArray = upcomingArray.sortedByStartDate()
        
        return TimePoint(date: date, cacheSummaryHash: hash, inProgressEvents: currentArray, upcomingEvents: upcomingArray)
    }
}
