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
            let currentEvent = Event(title: "Event \(index)", start: currentDate.addingTimeInterval(TimeInterval(-index * 3600)), end: currentDate.addingTimeInterval(TimeInterval(index * 3600)))
            events.append(currentEvent)
        }
        
        // Generating upcoming events
        for index in 1...upcomingEventsCount {
            let upcomingEvent = Event(title: "Event \(index + currentEventsCount)", start: currentDate.addingTimeInterval(TimeInterval(index * 3600)), end: currentDate.addingTimeInterval(TimeInterval((index + 1) * 3600)))
            events.append(upcomingEvent)
        }
        
        return events
    }

    
    override func setUp() {
        super.setUp()
        generator = TimePointGenerator()
        mockEvents = generateEvents(currentEventsCount: 1000, upcomingEventsCount: 1000)
    }
    
    override func tearDown() {
        generator = nil
        mockEvents = nil
        super.tearDown()
    }
    
    
    func testGenerateTimePointsWithCurrentAndUpcomingEvents() {
        
            
            let timePoints = generator.generateTimePoints(for: mockEvents)
            XCTAssertFalse(timePoints.isEmpty, "Expected time points to be generated.")
            XCTAssertTrue(timePoints.contains { $0.inProgressEvents.contains(where: { $0.title == "Event 1" }) }, "Expected Event 1 to be in progress.")
            XCTAssertTrue(timePoints.contains { $0.upcomingEvents.contains(where: { $0.title == "Event 2" }) }, "Expected Event 2 to be upcoming.")
    }
    
    func testGenerateTimePointForSpecificDate() {
        let testDate = Date().addingTimeInterval(5000) // This is during Event 2
        let timePoint = generator.generateTimePoint(for: testDate, from: mockEvents)
        XCTAssertTrue(timePoint.inProgressEvents.isEmpty, "Expected no events to be in progress at the test date.")
        XCTAssertTrue(timePoint.upcomingEvents.contains { $0.title == "Event 2" }, "Expected Event 2 to be upcoming at the test date.")
    }
    
    // Add more tests as necessary to cover all paths and edge cases
}
