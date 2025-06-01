//
//  WidgetConfigurationIntent.swift
//  How Long Left WidgetExtension
//
//  Created by Ryan on 24/9/2024.
//

import AppIntents
import Foundation
import WidgetKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public struct HLLWidgetConfigurationIntent: AppIntent, WidgetConfigurationIntent {
    
    public init() {}
    
    public static let intentClassName = "WidgetConfigurationIntentIntent"

    public static let title: LocalizedStringResource = "Widget Configuration Intent"
    public static let description = IntentDescription("")

    @Parameter(title: "Mirror App Settings", default: true)
    public var mirrorApp: Bool?

    @Parameter(title: "Show All Day Events")
    public var showAllDay: Bool?

    @Parameter(title: "Calendars")
    public var calendars: [CalendarAppEntity]?

    @Parameter(title: "Sort", default: .soonestToStartOrEnd)
   public  var sort: EventSortModeAppEnum?

   

    public func perform() async throws -> some IntentResult {
        .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static var calendarsParameterConfiguration: Self {
        "Choose Calendars"
    }
    static func calendarsParameterDisambiguationIntro(count: Int, calendars: CalendarAppEntity) -> Self {
        "There are \(count) options matching ‘\(calendars)’."
    }
    static func calendarsParameterConfirmation(calendars: CalendarAppEntity) -> Self {
        "Just to confirm, you wanted ‘\(calendars)’?"
    }
    static func sortParameterDisambiguationIntro(count: Int, sort: EventSortModeAppEnum) -> Self {
        "There are \(count) options matching ‘\(sort)’."
    }
    static func sortParameterConfirmation(sort: EventSortModeAppEnum) -> Self {
        "Just to confirm, you wanted ‘\(sort)’?"
    }
}
