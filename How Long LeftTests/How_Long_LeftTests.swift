//
//  How_Long_LeftTests.swift
//  How Long LeftTests
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
@testable import HowLongLeftKit
import XCTest

final class TimePointGeneratorTests: XCTestCase {
    private var generator: TimePointGenerator!
    private var mockEvents: [HLLEvent]!

    private func generateEvents(currentEventsCount: Int, upcomingEventsCount: Int) -> [HLLEvent] {
        var events = [HLLEvent]()

        let currentDate = Date()

        // Generating current events
        for index in 1...currentEventsCount {
            let currentEvent = HLLEvent(
                title: "Event \(index)",
                start: currentDate.addingTimeInterval(TimeInterval(-index * 3_600)),
                end: currentDate.addingTimeInterval(TimeInterval(index * 3_600)))
            events.append(currentEvent)
        }

        // Generating upcoming events
        for index in 1...upcomingEventsCount {
            let upcomingEvent = HLLEvent(
                title: "Event \(index + currentEventsCount)",
                start: currentDate.addingTimeInterval(TimeInterval(index * 3_600)),
                end: currentDate.addingTimeInterval(TimeInterval((index + 1) * 3_600)))
            events.append(upcomingEvent)
        }

        return events
    }

    override func setUp() {
        super.setUp()
        generator = TimePointGenerator(groupingMode: .countdownDate)
        mockEvents = generateEvents(currentEventsCount: 1_000, upcomingEventsCount: 1_000)
    }

    override func tearDown() {
        generator = nil
        mockEvents = nil
        super.tearDown()
    }

    // Add more tests as necessary to cover all paths and edge cases
}
