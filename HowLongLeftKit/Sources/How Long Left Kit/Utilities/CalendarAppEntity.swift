//
//  CalendarAppEntity.swift
//  How Long Left WidgetExtension
//
//  Created by Ryan on 24/9/2024.
//

import AppIntents
import Foundation

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)

public struct CalendarAppEntity: AppEntity {
    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Calendar Entity")

    
    public static let defaultQuery = CalendarAppEntityQuery()

    public var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    var displayString: String
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }

    init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }
}

public struct CalendarAppEntityQuery: EntityStringQuery {
    
    public init() {
        
    }
    
    public func defaultResult() async -> CalendarAppEntity? {
        return nil
    }
    
    public func entities(for _: [CalendarAppEntity.ID]) async throws -> [CalendarAppEntity] {
        []
    }

    public func entities(matching _: String) async throws -> [CalendarAppEntity] {
        []
    }

    public func suggestedEntities() async throws -> [CalendarAppEntity] {
        []
    }
}
