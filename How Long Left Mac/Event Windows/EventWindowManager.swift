//
//  EventWindowManager.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/11/2024.
//

import Foundation
import SwiftUI
import AppKit
import HowLongLeftKit

class EventWindowManager: NSObject, ObservableObject, NSWindowDelegate {
    @Published private var eventWindows: [UUID: EventWindow] = [:]
    private var allowMultipleWindows: Bool
    
    var container: MacDefaultContainer

    init(allowMultipleWindows: Bool, container: MacDefaultContainer) {
        self.allowMultipleWindows = allowMultipleWindows
        self.container = container
    }

    func openWindow(for event: Event) {
        if !allowMultipleWindows, let existingWindow = eventWindows.values.first(where: { $0.event.id == event.id }) {
            existingWindow.activate()
        
        } else {
     
            let newWindow = EventWindow(event: event, container: container)

            newWindow.window?.delegate = self
            
            eventWindows[newWindow.id] = newWindow
        }
    }
    
    func windowWillClose(_ notification: Notification) {
       
        // Get window id from notification object
        guard let window = notification.object as? NSWindow, let windowID = window.identifier else {
            print("Failed to get window ID from windowWillClose notification")
            return
        }
        
        guard let windowID = UUID(uuidString: windowID.rawValue as String) else {
            print("Failed to convert window ID to UUID")
            return
        }
        
        print("Window with ID \(windowID) closed")
            
        eventWindows.removeValue(forKey: windowID)
        
    }

}
