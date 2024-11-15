//
//  EventCustomWindow.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/11/2024.
//

import Foundation
import Cocoa

class EventCustomWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        self.setupWindow()
    }
    
    private func setupWindow() {
        // Observe window resizing events
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize(_:)), name: NSWindow.didResizeNotification, object: self)
    }
    
    @objc private func windowDidResize(_ notification: Notification) {
        adjustTitleVisibility()
    }
    
    private func adjustTitleVisibility() {
        // Hide title bar if window width is below 300px
        if self.frame.width < 300 {
            self.titleVisibility = .hidden
            self.titlebarAppearsTransparent = true
        } else {
            self.titleVisibility = .visible
            self.titlebarAppearsTransparent = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSWindow.didResizeNotification, object: self)
    }
}
