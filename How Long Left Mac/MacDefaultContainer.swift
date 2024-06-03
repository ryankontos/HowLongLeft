//
//  MacDefaultContainer.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Foundation
import HowLongLeftKit

class MacDefaultContainer: DefaultContainer {
    
    public lazy var settingsWindow = SettingsWindow(calendarManager: self.calendarPrefsManager)
    
    public lazy var statusItemEventFilter = EventCache(calendarReader: self.calendarReader, calendarProvider: self.calendarPrefsManager, calendarContexts: [MacCalendarContexts.statusItem.rawValue])
    
}
