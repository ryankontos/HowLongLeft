//
//  EventWindow.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/11/2024.
//

import Foundation
import SwiftUI
import HowLongLeftKit

class EventWindow: ObservableObject, Identifiable {
    
    static let defaultSize: CGSize = CGSize(width: 250, height: 250)
    
    static let aspectRatio: CGFloat = 1
    
    static let minWidth: CGFloat = 200
    static let minHeight: CGFloat = 200
    
    static let maxWidth: CGFloat = 450
    static let maxHeight: CGFloat = 450
    
    let id = UUID()
    let event: Event
    weak var window: NSWindow?
    
    private var lastSavedSize: CGSize?
    
    var floating: Bool {
        get {
            return window?.level == .floating
        }
        
        set {
            window?.level = newValue ? .floating : .normal
            objectWillChange.send()
        }
    }
    
    init(event: Event, container: MacDefaultContainer) {
        self.event = event
        
        let content = EventWindowViewContainer(event: event, calendarSource: container.calendarReader, eventWindow: self)
        let hostingController = NSHostingController(rootView: content)
        
        let window = NSWindow()
        
        window.identifier = NSUserInterfaceItemIdentifier(rawValue: id.uuidString)
        window.setFrameAutosaveName(id.uuidString)
        window.setContentSize(EventWindow.defaultSize)
        window.aspectRatio = NSSize(width: 1, height: 1)
        window.contentAspectRatio = NSSize(width: 1, height: 1)
        window.isMovableByWindowBackground = true
        // Configure style mask
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView]
        window.title = event.title
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true
        window.makeMain()
        NSApp.activate(ignoringOtherApps: true)
        
        // Enforce min and max size constraints using Auto Layout
        let minSizeConstraintWidth = hostingController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: EventWindow.minWidth)
        let minSizeConstraintHeight = hostingController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: EventWindow.minHeight)
        let maxSizeConstraintWidth = hostingController.view.widthAnchor.constraint(lessThanOrEqualToConstant: EventWindow.maxWidth)
        let maxSizeConstraintHeight = hostingController.view.heightAnchor.constraint(lessThanOrEqualToConstant: EventWindow.maxHeight)
        
        NSLayoutConstraint.activate([
            minSizeConstraintWidth,
            minSizeConstraintHeight,
            maxSizeConstraintWidth,
            maxSizeConstraintHeight
        ])
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        window.contentView?.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: window.contentView!.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor)
        ])
        
        self.window = window
    }

    public func toggleMaxSizeLock(enabled: Bool) {
        guard let window = window else { return }
        
        if enabled {
            // Save the current size
            lastSavedSize = window.frame.size
            
            // Animate to max size
            let maxSizeFrame = NSRect(
                x: window.frame.origin.x,
                y: window.frame.origin.y - (EventWindow.maxHeight - window.frame.size.height),
                width: EventWindow.maxWidth,
                height: EventWindow.maxHeight
            )
            window.setFrame(maxSizeFrame, display: true, animate: true)
            
            // Disable resizing
            window.styleMask.remove(.resizable)
        } else {
            // Enable resizing
            window.styleMask.insert(.resizable)
            
            // Animate back to last saved size or default size
            let targetSize = lastSavedSize ?? EventWindow.defaultSize
            let targetFrame = NSRect(
                x: window.frame.origin.x,
                y: window.frame.origin.y - (targetSize.height - window.frame.size.height),
                width: targetSize.width,
                height: targetSize.height
            )
            window.setFrame(targetFrame, display: true, animate: true)
        }
    }

    func activate() {
        window?.makeKeyAndOrderFront(nil)
    }
    
    deinit {
        print("Deinit EventWindow")
    }
}
