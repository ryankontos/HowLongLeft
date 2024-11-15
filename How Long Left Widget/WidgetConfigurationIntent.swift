//
//  WidgetConfigurationIntent.swift
//  How Long Left WidgetExtension
//
//  Created by Ryan on 24/9/2024.
//

import Foundation
import AppIntents
import WidgetKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
struct HLLWidgetConfigurationIntent: AppIntent, WidgetConfigurationIntent {
    static let intentClassName = "WidgetConfigurationIntentIntent"

    static var title: LocalizedStringResource = "Widget Configuration Intent"
    static var description = IntentDescription("")

    @Parameter(title: "Mirror App Settings", default: true)
    var mirrorApp: Bool?

    @Parameter(title: "Show All Day Events")
    var showAllDay: Bool?

    @Parameter(title: "Calendars")
    var calendars: [CalendarAppEntity]?

    @Parameter(title: "Sort", default: .soonestToStartOrEnd)
    var sort: EventSortModeAppEnum?

    static var parameterSummary: some ParameterSummary {
        Switch(\.$mirrorApp) {
            Case(true) {
                Summary()
            }

            DefaultCase {
                Summary {
                    \.$mirrorApp
                }
            }
        }
    }

    func perform() async throws -> some IntentResult {

        return .result()
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
