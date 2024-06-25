//
//  MacDefaultContainer.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Foundation
import HowLongLeftKit

class MacDefaultContainer: DefaultContainer {

    public lazy var statusItemStore: StatusItemStore? = {
        // The closure provides a reference to self
        return StatusItemStore(container: self)
    }()
    
    public lazy var settingsWindow = SettingsWindow(container: self)
    
    public lazy var statusItemEventFilter = EventCache(
        calendarReader: self.calendarReader,
        calendarProvider: self.calendarPrefsManager,
        calendarContexts: [MacCalendarContexts.statusItem.rawValue],
        hiddenEventManager: self.hiddenEventManager
    )
    
    public lazy var eventListSettingsManager = EventListSettingsManager(domain: "MacMainMenu")
    
    public lazy var customStatusItemManager = CustomStatusItemStore()
    
    override init() {
        super.init()
        // Explicitly access the lazy property to trigger initialization
        _ = statusItemStore
    }
}
