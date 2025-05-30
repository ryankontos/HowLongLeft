//
//  EventWindow.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/11/2024.
//

import Foundation
import HowLongLeftKit
import SwiftUI

class EventWindow: ObservableObject, Identifiable {
    static let defaultSize = CGSize(width: 250, height: 250)
    static let aspectRatio: CGFloat = 1
    static let minWidth: CGFloat = 200
    static let minHeight: CGFloat = 200
    static let maxWidth: CGFloat = 450
    static let maxHeight: CGFloat = 450

    var eventProvider: TimePointStore
    let id = UUID()
    @Published var selectedEventID: String?
    weak var window: NSWindow?
    private var lastSavedSize: CGSize?

    @MainActor func getEvent() -> HLLCalendarEvent? {
        let currentPoint = eventProvider.currentPoint
        let event = getChosenEvent() ?? currentPoint?.fetchSingleEvent(accordingTo: .preferInProgress)

        self.window?.title = event?.title ?? "No Event"

        return event
    }

    @MainActor func getChosenEvent() -> HLLCalendarEvent? {
        let currentPoint = eventProvider.currentPoint
        return currentPoint?.allEvents.first { $0.eventIdentifier == selectedEventID }
    }

    @MainActor
    var floating: Bool {
        get {
            window?.level == .floating
        }
        set {
            window?.level = newValue ? .floating : .normal
            objectWillChange.send()
        }
    }

    @MainActor
    init(event: HLLCalendarEvent?, container: MacDefaultContainer, eventProvider: TimePointStore) {
        self.selectedEventID = event?.eventIdentifier
        self.eventProvider = eventProvider

        let content = EventWindowViewContainer(calendarSource: container.calendarReader, eventWindow: self, defaultContainer: container, pointStore: eventProvider)
        let hostingController = NSHostingController(rootView: content)
        let window = NSWindow()

        window.identifier = NSUserInterfaceItemIdentifier(rawValue: id.uuidString)
        window.setFrameAutosaveName(id.uuidString)
        window.setContentSize(Self.defaultSize)
        window.aspectRatio = NSSize(width: 1, height: 1)
        window.contentAspectRatio = NSSize(width: 1, height: 1)
        window.isMovableByWindowBackground = true
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView]
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true
        window.makeMain()
        NSApp.activate(ignoringOtherApps: true)

        let minSizeConstraintWidth = hostingController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: Self.minWidth)
        let minSizeConstraintHeight = hostingController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: Self.minHeight)
        let maxSizeConstraintWidth = hostingController.view.widthAnchor.constraint(lessThanOrEqualToConstant: Self.maxWidth)
        let maxSizeConstraintHeight = hostingController.view.heightAnchor.constraint(lessThanOrEqualToConstant: Self.maxHeight)

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

    @MainActor
    func toggleMaxSizeLock(enabled: Bool) {
        guard let window else { return }

        if enabled {
            lastSavedSize = window.frame.size

            let maxSizeFrame = NSRect(
                x: window.frame.origin.x,
                y: window.frame.origin.y - (Self.maxHeight - window.frame.size.height),
                width: Self.maxWidth,
                height: Self.maxHeight
            )
            window.setFrame(maxSizeFrame, display: true, animate: true)
            window.styleMask.remove(.resizable)
        } else {
            window.styleMask.insert(.resizable)
            let targetSize = lastSavedSize ?? Self.defaultSize
            let targetFrame = NSRect(
                x: window.frame.origin.x,
                y: window.frame.origin.y - (targetSize.height - window.frame.size.height),
                width: targetSize.width,
                height: targetSize.height
            )
            window.setFrame(targetFrame, display: true, animate: true)
        }
    }

    @MainActor
    func activate() {
        window?.makeKeyAndOrderFront(nil)
    }

    deinit {
        //print("Deinit EventWindow")
    }
}
