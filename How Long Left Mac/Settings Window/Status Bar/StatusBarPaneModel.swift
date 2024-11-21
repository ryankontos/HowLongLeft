//
//  StatusBarPaneModel.swift
//  How Long Left Mac
//
//  Created by Ryan on 11/8/2024.
//

import Foundation
import HowLongLeftKit

@MainActor
class StatusBarPaneModel: ObservableObject {
    enum MultiTypeEventDisplayPickerOptions: Int, CaseIterable, Identifiable {
        case soonest
        case currentFirst
        case upcomingFirst

        var id: String {
            String(self.rawValue)
        }
    }

    init(settings: StatusItemSettings, store: StatusItemStore) {
        self.settings = settings
        self.showTitles = settings.showTitles
        self.store = store
        self.titleLimit = Double(Int(settings.titleLengthLimit))
        self.showCountdowns = settings.showCountdowns

        self.showIndicatorDot = settings.showIndicatorDot

        self.showCurrentEvents = EventFetchRule(rawValue: Int(settings.eventFetchRule)) != .upcomingOnly
        self.showUpcomingEvents = EventFetchRule(rawValue: Int(settings.eventFetchRule)) != .inProgressOnly

        self.showPercentageText = settings.showPercentageText
        
        self.hidesWhenEmpty = settings.hidesWhenEmpty
    }

    var settings: StatusItemSettings

    var store: StatusItemStore

    @Published var showCurrentEvents: Bool {
        didSet {
            processEventRule()
        }
    }
    @Published var showUpcomingEvents: Bool {
        didSet {
            processEventRule()
        }
    }

    @Published var multiTypeSelection: MultiTypeEventDisplayPickerOptions = .soonest {
        didSet {
            processEventRule()
        }
    }

    @Published var showTitles: Bool {
        didSet {
            settings.showTitles = showTitles

            store.settingsStore.saveSettings(settings: settings)
        }
    }

    @Published var hidesWhenEmpty: Bool {
        didSet {
            settings.hidesWhenEmpty = hidesWhenEmpty

            store.settingsStore.saveSettings(settings: settings)
        }
    }
    
    @Published var showCountdowns: Bool {
        didSet {
            settings.showCountdowns = showCountdowns

            store.settingsStore.saveSettings(settings: settings)
        }
    }

    @Published var titleLimit: Double {
        didSet {
            settings.titleLengthLimit = Double(Int(titleLimit))
            store.settingsStore.saveSettings(settings: settings)
        }
    }

    @Published var showIndicatorDot: Bool {
        didSet {
            settings.showIndicatorDot = showIndicatorDot

            store.settingsStore.saveSettings(settings: settings)
        }
    }

    @Published var showPercentageText: Bool {
        didSet {
            settings.showPercentageText = showPercentageText

            store.settingsStore.saveSettings(settings: settings)
        }
    }

    func processEventRule() {
        switch (showCurrentEvents, showUpcomingEvents) {
        case (true, false):
            settings.eventFetchRule = Int16(EventFetchRule.inProgressOnly.rawValue)

        case (false, true):
            settings.eventFetchRule = Int16(EventFetchRule.upcomingOnly.rawValue)

        case (false, false):
            settings.eventFetchRule = Int16(EventFetchRule.noEvents.rawValue)

        case (true, true):
            switch multiTypeSelection {
            case .soonest:
                settings.eventFetchRule = Int16(EventFetchRule.soonestCountdownDate.rawValue)

            case .currentFirst:
                settings.eventFetchRule = Int16(EventFetchRule.preferInProgress.rawValue)

            case .upcomingFirst:
                settings.eventFetchRule = Int16(EventFetchRule.preferUpcoming.rawValue)
            }
        }

        store.settingsStore.saveSettings(settings: settings)
    }
}
