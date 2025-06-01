//
//  EventFilteringOptionsProvider.swift
//
//
//  Created by Ryan on 19/6/2024.
//

import Foundation
import EventKit
import Combine

@MainActor
public protocol CalendarSettingsProvider: ObservableObject {
    var objectWillChange: ObservableObjectPublisher { get }
    func getAllowedCalendars(matchingContextIn contexts: Set<String>) -> [HLLCalendar]
    func getAllDayAllowed() -> Bool
    func updateForNewCals()
}
