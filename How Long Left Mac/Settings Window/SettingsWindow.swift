//
//  SettingsWindow.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Foundation
import Settings
import AppKit
import HowLongLeftKit

class SettingsWindow: ObservableObject {
    
    let calendarManager: EventFilterDefaultsManager
    
    init(calendarManager: EventFilterDefaultsManager) {
        self.calendarManager = calendarManager
    }
    
    func open() {
        settingsWindowController.window?.level = .floating
        settingsWindowController.hidesToolbarForSingleItem = false
       
        settingsWindowController.show()
        
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    private lazy var settingsWindowController = SettingsWindowController(
        panes: [
            Settings.Pane(
                identifier: Settings.PaneIdentifier.general,
                title: "General",
                toolbarIcon: NSImage(systemSymbolName: "gear", accessibilityDescription: nil)!
                
            ) {
                GeneralPane()
            },
            
            Settings.Pane(
                identifier: Settings.PaneIdentifier.calendars,
                title: "Calendars",
                toolbarIcon: NSImage(systemSymbolName: "calendar", accessibilityDescription: nil)!
                
            ) {
                CalendarsPane()
                    .environmentObject(calendarManager)
            },
            
        ]
    )

    
}
