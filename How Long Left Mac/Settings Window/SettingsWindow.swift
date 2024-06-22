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
    
    let calendarManager: EventFetchSettingsManager
    let eventListSettingsManager: EventListSettingsManager
    
    init(container: MacDefaultContainer) {
        self.calendarManager = container.calendarPrefsManager
        self.eventListSettingsManager = container.eventListSettingsManager
    }
    
    func open() {
        
        
        NSApp.deactivate()
        NSApp.activate(ignoringOtherApps: true)
        
        DispatchQueue.main.async { [self] in
            
            if #available(macOS 14.0, *) {
                NSApp.activate()
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }
            
            settingsWindowController.close()
            
            settingsWindowController.window?.collectionBehavior = [.auxiliary, .primary]
            
            settingsWindowController.window?.level = .normal
            settingsWindowController.hidesToolbarForSingleItem = false
            
            settingsWindowController.show()
            settingsWindowController.window!.makeKeyAndOrderFront(nil)
            settingsWindowController.window!.makeMain()
            
           
            
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
                    .environmentObject(eventListSettingsManager)
                    .environmentObject(calendarManager)
            },
            
            Settings.Pane(
                identifier: Settings.PaneIdentifier.calendars,
                title: "Calendars",
                toolbarIcon: NSImage(systemSymbolName: "calendar", accessibilityDescription: nil)!
                
            ) {
                CalendarsPane()
                    .environmentObject(calendarManager)
            },
            
            Settings.Pane(
                identifier: Settings.PaneIdentifier.statusbar,
                title: "Status Bar",
                toolbarIcon: NSImage(systemSymbolName: "clock", accessibilityDescription: nil)!
                
            ) {
                StatusBarPane()
                    .environmentObject(calendarManager)
            },
            
        ]
    )

    
}
