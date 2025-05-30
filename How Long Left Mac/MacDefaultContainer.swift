//
//  MacDefaultContainer.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Foundation
import HowLongLeftKit

@MainActor
class MacDefaultContainer: HLLCoreServicesContainer {
    lazy var statusItemStore: StatusItemStore? = {
        StatusItemStore(container: self)
    }()

    lazy var eventWindowManager: EventWindowManager? = {
        EventWindowManager(allowMultipleWindows: true, container: self)
    }()

    lazy var settingsWindow: SettingsWindow = {
        SettingsWindow(container: self)
    }()

    lazy var statusItemEventFilter: CalendarEventCache = {
        CalendarEventCache(
            calendarReader: self.calendarReader,
            calendarProvider: self.calendarPrefsManager,
            calendarContexts: [MacCalendarContexts.statusItem.rawValue],
            hiddenEventManager: self.hiddenEventManager, id: "MacDefaultContainer"
        )
    }()

    lazy var eventListSettingsManager: EventListSettingsManager = {
        EventListSettingsManager(domain: "MacMainMenu")
    }()

    lazy var customStatusItemManager: StatusItemConfigurationStore = {
        StatusItemConfigurationStore()
    }()

    @MainActor
    override init(id: String) {
        super.init(id: id)
        
       
            // Explicitly access the actor-isolated properties
            _ = statusItemStore
            _ = eventWindowManager
        }
    
}
