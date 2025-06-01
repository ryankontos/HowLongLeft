//
//  WidgetTimePointManagerTests.swift
//  How Long Left Tests
//
//  Created by Ryan on 23/11/2024.
//

import Testing
import Foundation
@testable import HowLongLeftKit

@MainActor
@Suite("WidgetTimePointManager Tests")
struct WidgetTimePointManagerTests {
    var mockEventCache = MockEventCache()
    let userDefaults = UserDefaults(suiteName: "testSuite")!
    lazy var widgetTimePointManager = WidgetTimePointManager(eventCache: mockEventCache)

    @Test("When there are no time points, generateTimelineEntries should return an empty array")
    mutating func test_generateTimelineEntries_noTimePoints() {
        // Given
        widgetTimePointManager.timePointStore.points = []

        // When
        let entries = widgetTimePointManager.generateTimelineEntries()

        // Then
        #expect(entries.isEmpty)
    }

    @Test("When there are time points, generateTimelineEntries should return the correct entries")
    mutating func test_generateTimelineEntries_withTimePoints() {
        // Given
        let currentDate = Date()
        let mockTimePoint1 = TimePoint(
            date: currentDate.addingTimeInterval(3600),
            cacheSummaryHash: "hash1",
            inProgressEvents: [HLLCalendarEvent.example],
            upcomingEvents: []
        )
        let mockTimePoint2 = TimePoint(
            date: currentDate.addingTimeInterval(7200),
            cacheSummaryHash: "hash2",
            inProgressEvents: [],
            upcomingEvents: [HLLCalendarEvent.example]
        )
        widgetTimePointManager.timePointStore.points = [mockTimePoint1, mockTimePoint2]

        // When
        let entries = widgetTimePointManager.generateTimelineEntries()

        // Then
        #expect(entries.count == 2)
        #expect(entries[0].timePoint == mockTimePoint1)
        #expect(entries[1].timePoint == mockTimePoint2)
    }

    @Test("It should add padding entries when enablePadding is true")
    mutating func test_generateTimelineEntries_withPadding() {
        // Given
        let currentDate = Date()
        let mockTimePoint = TimePoint(
            date: currentDate.addingTimeInterval(3600),
            cacheSummaryHash: "hash1",
            inProgressEvents: [HLLCalendarEvent.example],
            upcomingEvents: []
        )
        widgetTimePointManager.timePointStore.points = [mockTimePoint]

        // When
        let entries = widgetTimePointManager.generateTimelineEntries(interval: 600, enablePadding: true)

        // Then
        #expect(entries.count > 1) // Padding entries included
        #expect(entries[0].timePoint == mockTimePoint)
    }

    @Test("When enablePadding is false, it should not add extra entries")
    mutating func test_generateTimelineEntries_noPadding() {
        // Given
        let currentDate = Date()
        let mockTimePoint = TimePoint(
            date: currentDate.addingTimeInterval(3600),
            cacheSummaryHash: "hash1",
            inProgressEvents: [HLLCalendarEvent.example],
            upcomingEvents: []
        )
        widgetTimePointManager.timePointStore.points = [mockTimePoint]

        // When
        let entries = widgetTimePointManager.generateTimelineEntries(interval: 600, enablePadding: false)

        // Then
        #expect(entries.count == 1) // No extra entries
        #expect(entries[0].timePoint == mockTimePoint)
    }

    @Test("It should save the correct cache hash to user defaults")
    mutating func test_saveCacheHash() {
        // Given
        let mockTimePoint = TimePoint(
            date: Date(),
            cacheSummaryHash: "newHash",
            inProgressEvents: [],
            upcomingEvents: []
        )
        widgetTimePointManager.timePointStore.points = [mockTimePoint]

        // When
        _ = widgetTimePointManager.generateTimelineEntries()

        // Then
        #expect(userDefaults.string(forKey: "WidgetComputedHash") == "newHash")
    }
}
