//
//  CalendarAppEntity.swift
//  How Long Left WidgetExtension
//
//  Created by Ryan on 24/9/2024.
//

import AppIntents
import Foundation

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct CalendarAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Calendar Entity")

    struct CalendarAppEntityQuery: EntityStringQuery {
        func entities(for _: [CalendarAppEntity.ID]) async throws -> [CalendarAppEntity] {
            []
        }

        func entities(matching _: String) async throws -> [CalendarAppEntity] {
            []
        }

        func suggestedEntities() async throws -> [CalendarAppEntity] {
            []
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
