//
//  EventWindowManager.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/11/2024.
//

import AppKit
import Foundation
import HowLongLeftKit
import SwiftUI

class EventWindowManager: NSObject, ObservableObject, NSWindowDelegate {
    @Published private var eventWindows: [UUID: EventWindowWeakWrapper] = [:]
    private var allowMultipleWindows: Bool

    var container: MacDefaultContainer

    init(allowMultipleWindows: Bool, container: MacDefaultContainer) {
        self.allowMultipleWindows = allowMultipleWindows
        self.container = container
    }

    @MainActor
    func openWindow(for event: Event, withEventProvider: TimePointStore) {
        if !allowMultipleWindows {
            Task {
                for wrapper in eventWindows.values {
                    if let existingWindow = wrapper.value,
                       let existingEvent = existingWindow.getEvent(),
                       existingEvent.eventID == event.eventID {
                        existingWindow.activate()
                        return
                    }
                }

                // If no existing window is found, create a new one
                createNewWindow(for: event, withEventProvider: withEventProvider)
            }
        } else {
            createNewWindow(for: event, withEventProvider: withEventProvider)
        }
    }

    @MainActor private func createNewWindow(for event: Event, withEventProvider: TimePointStore) {
        let newWindow = EventWindow(event: event, container: container, eventProvider: withEventProvider)
        newWindow.window?.delegate = self
        eventWindows[newWindow.id] = EventWindowWeakWrapper(value: newWindow)
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              let windowID = window.identifier?.rawValue,
              let id = UUID(uuidString: windowID) else { return }

        eventWindows[id] = nil
        //print("EventWindowWeakWrapper for \(id) removed.")
    }
}

class EventWindowWeakWrapper {
    weak var value: EventWindow?
    init(value: EventWindow? = nil) {
        self.value = value
    }
}
