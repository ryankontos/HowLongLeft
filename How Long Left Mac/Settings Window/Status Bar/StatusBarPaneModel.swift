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
            return String(self.rawValue)
        }
        
    }
    
    init(settings: StatusItemSettings, store: StatusItemStore) {
        self.settings = settings
        self.showTitles = settings.showTitles
        self.store = store
        self.titleLimit = Double(Int(settings.titleLengthLimit))
        self.showCountdowns = settings.showCountdowns
        
        self.showIndicatorDot = settings.showIndicatorDot
        
        self.showCurrentEvents = SingleEventFetchRule(rawValue: Int(settings.eventFetchRule)) != .upcomingOnly
        self.showUpcomingEvents = SingleEventFetchRule(rawValue: Int(settings.eventFetchRule)) != .inProgressOnly
        
        self.showPercentageText = settings.showPercentageText
        
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
            settings.eventFetchRule = Int16(SingleEventFetchRule.inProgressOnly.rawValue)
        case (false, true):
            settings.eventFetchRule = Int16(SingleEventFetchRule.upcomingOnly.rawValue)
        case (false, false):
            settings.eventFetchRule = Int16(SingleEventFetchRule.noEvents.rawValue)
        case (true, true):
            switch multiTypeSelection {
            case .soonest:
                settings.eventFetchRule = Int16(SingleEventFetchRule.soonestCountdownDate.rawValue)
            case .currentFirst:
                settings.eventFetchRule = Int16(SingleEventFetchRule.preferInProgress.rawValue)
            case .upcomingFirst:
                settings.eventFetchRule = Int16(SingleEventFetchRule.preferUpcoming.rawValue)
            }
        }
        
        store.settingsStore.saveSettings(settings: settings)
        
    }

    
    
}
