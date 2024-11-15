//
//  How_Long_LeftTests.swift
//  How Long LeftTests
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
import XCTest
@testable import HowLongLeftKit

class TimePointGeneratorTests: XCTestCase {

    var generator: TimePointGenerator!
    var mockEvents: [Event]!

    func generateEvents(currentEventsCount: Int, upcomingEventsCount: Int) -> [Event] {
        var events = [Event]()

        let currentDate = Date()

        // Generating current events
        for index in 1...currentEventsCount {
            let currentEvent = Event(
                title: "Event \(index)",
                start: currentDate.addingTimeInterval(TimeInterval(-index * 3600)),
                end: currentDate.addingTimeInterval(TimeInterval(index * 3600)))
            events.append(currentEvent)
        }

        // Generating upcoming events
        for index in 1...upcomingEventsCount {
            let upcomingEvent = Event(
                title: "Event \(index + currentEventsCount)",
                start: currentDate.addingTimeInterval(TimeInterval(index * 3600)),
                end: currentDate.addingTimeInterval(TimeInterval((index + 1) * 3600)))
            events.append(upcomingEvent)
        }

        return events
    }

    override func setUp() {
        super.setUp()
        generator = TimePointGenerator(groupingMode: .countdownDate)
        mockEvents = generateEvents(currentEventsCount: 1000, upcomingEventsCount: 1000)
    }

    override func tearDown() {
        generator = nil
        mockEvents = nil
        super.tearDown()
    }

    // Add more tests as necessary to cover all paths and edge cases
}
