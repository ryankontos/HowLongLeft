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

    var controller: SettingsWindowController?

    init(container: MacDefaultContainer) {
        self.calendarManager = container.calendarPrefsManager
        self.eventListSettingsManager = container.eventListSettingsManager
    }

    func open() {

        NSApp.deactivate()
        NSApp.activate(ignoringOtherApps: true)

        if let existing = controller {
            existing.close()
            controller = nil
        }

        let settingsWindowController = getSettingsController()

            settingsWindowController.window!.delegate = self
        settingsWindowController.window!.collectionBehavior = [.transient, .auxiliary]

        settingsWindowController.window!.hidesOnDeactivate = false
        settingsWindowController.window?.level = .floating
            settingsWindowController.hidesToolbarForSingleItem = false

            settingsWindowController.isAnimated = false
            settingsWindowController.show()

            settingsWindowController.window!.makeMain()
            settingsWindowController.window!.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)

        self.controller = settingsWindowController

    }

    func windowDidResignKey(_ notification: Notification) {

        print("Settings window resigned key")
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func getSettingsController() -> SettingsWindowController {

        return SettingsWindowController(
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
                    identifier: Settings.PaneIdentifier.statusItem,
                    title: "Status Bar",
                    toolbarIcon: NSImage(systemSymbolName: "clock", accessibilityDescription: nil)!

                ) {
                    StatusBarPane()
                        .environmentObject(calendarManager)
                }

            ]
        )

    }

}
