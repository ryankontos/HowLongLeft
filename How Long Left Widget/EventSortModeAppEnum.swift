//
//  EventSortModeAppEnum.swift
//  How Long Left WidgetExtension
//
//  Created by Ryan on 24/9/2024.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
enum EventSortModeAppEnum: String, AppEnum {
    case inProgressOnly
    case upcomingOnly
    case soonestToStartOrEnd

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Event Sort Mode")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .inProgressOnly: "In Progress Only",
        .upcomingOnly: "Upcoming Only",
        .soonestToStartOrEnd: "Next To Start or End"
    ]
}
