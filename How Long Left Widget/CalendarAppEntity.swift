//
//  CalendarAppEntity.swift
//  How Long Left WidgetExtension
//
//  Created by Ryan on 24/9/2024.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct CalendarAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Calendar Entity")

    struct CalendarAppEntityQuery: EntityStringQuery {
        func entities(for identifiers: [CalendarAppEntity.ID]) async throws -> [CalendarAppEntity] {

            return []
        }

        func entities(matching string: String) async throws -> [CalendarAppEntity] {

            return []
        }

        func suggestedEntities() async throws -> [CalendarAppEntity] {

            return []
        }
    }
    static var defaultQuery = CalendarAppEntityQuery()

    var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    var displayString: String
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }

    init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }
}
