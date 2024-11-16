//
//  MacDefaultContainer.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Foundation
import HowLongLeftKit

class MacDefaultContainer: HLLCoreServicesContainer {
    lazy var statusItemStore: StatusItemStore? = {
        StatusItemStore(container: self)
    }()

    lazy var eventWindowManager: EventWindowManager? = {
        EventWindowManager(allowMultipleWindows: true, container: self)
    }()

    lazy var settingsWindow = SettingsWindow(container: self)

    lazy var statusItemEventFilter = EventCache(
        calendarReader: self.calendarReader,
        calendarProvider: self.calendarPrefsManager,
        calendarContexts: [MacCalendarContexts.statusItem.rawValue],
        hiddenEventManager: self.hiddenEventManager, id: "MacDefaultContainer"
    )

    lazy var eventListSettingsManager = EventListSettingsManager(domain: "MacMainMenu")

    lazy var customStatusItemManager = StatusItemConfigurationStore()

    override init(id: String) {
        super.init(id: id)

        _ = statusItemStore
        _ = eventWindowManager
    }
}
