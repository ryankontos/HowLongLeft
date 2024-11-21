//
//  SettingsWindow.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import AppKit
import Foundation
import HowLongLeftKit
import Settings
import SwiftUI

@MainActor
class SettingsWindow: ObservableObject {
    let calendarManager: EventFetchSettingsManager
    let eventListSettingsManager: EventListSettingsManager
    unowned var container: MacDefaultContainer

    var window: NSWindow?

    init(container: MacDefaultContainer) {
        self.container = container
        self.calendarManager = container.calendarPrefsManager
        self.eventListSettingsManager = container.eventListSettingsManager
    }

    func open() {
        NSApp.deactivate()
        NSApp.activate(ignoringOtherApps: true)

        window?.close()
        window = nil

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 715, height: 540),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)

        window?.center()
        window?.isReleasedWhenClosed = false
        window?.title = "How Long Left Settings"
        window?.setFrameAutosaveName("How Long Left Settings")
        window?.contentView = NSHostingView(rootView: SettingsWindowContentView(container: container))
        window?.makeKeyAndOrderFront(nil)
    }
}
