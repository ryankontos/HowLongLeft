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

class SettingsWindow: NSObject, ObservableObject, NSWindowDelegate {
    
    let calendarManager: EventFilterDefaultsManager
    let eventListSettingsManager: EventListSettingsManager
    
    init(container: MacDefaultContainer) {
        self.calendarManager = container.calendarPrefsManager
        self.eventListSettingsManager = container.eventListSettingsManager
    }
    
    func open() {
        
       
     
        
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            
            settingsWindowController.window!.delegate = self
            settingsWindowController.window!.collectionBehavior = [.primary, .fullScreenNone]
            
            settingsWindowController.window?.level = .normal
            settingsWindowController.hidesToolbarForSingleItem = false
        
            settingsWindowController.isAnimated = false
            settingsWindowController.show()
            
       
                self.settingsWindowController.window!.makeKeyAndOrderFront(nil)
                self.settingsWindowController.window!.makeMain()
              
            
            if #available(macOS 14.0, *) {
                NSApp.activate()
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }
            
            
        }
        
        
    }
    
    func windowDidResignKey(_ notification: Notification) {
        
        print("Settings window resigned key")
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
            
        ]
    )

    
}
