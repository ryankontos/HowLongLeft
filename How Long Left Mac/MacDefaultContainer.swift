//
//  MacDefaultContainer.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Foundation
import HowLongLeftKit

class MacDefaultContainer: HLLCoreServicesContainer {

    public lazy var statusItemStore: StatusItemStore? = {

        return StatusItemStore(container: self)
    }()
    
    public lazy var eventWindowManager: EventWindowManager? = {

        return EventWindowManager(allowMultipleWindows: true, container: self)
    }()
    
    public lazy var settingsWindow = SettingsWindow(container: self)

    public lazy var statusItemEventFilter = EventCache(
        calendarReader: self.calendarReader,
        calendarProvider: self.calendarPrefsManager,
        calendarContexts: [MacCalendarContexts.statusItem.rawValue],
        hiddenEventManager: self.hiddenEventManager, id: "MacDefaultContainer"
    )

    public lazy var eventListSettingsManager = EventListSettingsManager(domain: "MacMainMenu")

    public lazy var customStatusItemManager = StatusItemConfigurationStore()

    override init(id: String) {
        
        super.init(id: id)

        _ = statusItemStore
        _ = eventWindowManager
        
    }
}
