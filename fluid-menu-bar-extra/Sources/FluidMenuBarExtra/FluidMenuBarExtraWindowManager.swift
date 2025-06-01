//
//  FluidMenuBarExtraStatusItem.swift
//  FluidMenuBarExtra
//
//  Created by Lukas Romsicki on 2022-12-17.
//  Copyright © 2022 Lukas Romsicki.
//

import AppKit
import SwiftUI
import Combine

/// An individual element displayed in the system menu bar that displays a window when triggered.
///
///
///
///

public class FluidMenuBarExtraWindowManager: NSObject, NSWindowDelegate, ObservableObject {

    private var mainWindow: ModernMenuBarExtraWindow?
    private weak var subWindowMonitor: AnyObject?
    public weak var currentSubwindowDelegate: SubwindowDelegate?
    private var statusItemHostingView: NSHostingView<StatusItemRootView>?
    public var statusItem: NSStatusItem!
    private var sizePassthrough = PassthroughSubject<CGSize, Never>()
    private var sizeCancellable: AnyCancellable?
    private var localEventMonitor: EventMonitor?
    private var globalEventMonitor: EventMonitor?
    private var mouseMonitor: EventMonitor?
    private var mainWindowVisible = false
    private var mouseWorkItem: DispatchWorkItem?
    private let mouseQueue = DispatchQueue(label: "com.ryankontos.fluidmenubarextra.mouseQueue")
    public let speedCalculator = MouseSpeedCalculator()
    
    let windowQueue = DispatchQueue(label: "FluidMenuBarExtraWindowManager.WindowQueue")
    
    private var hideStatusItemPending = false
    
    private let mainWindowContentGetter: () -> AnyView
    
    var title: String
    var sessionID = UUID()
    var latestCursorPosition: NSPoint?
    let queue = DispatchQueue(label: "MouseMovedQueue")
    private var workItem: DispatchWorkItem?

    public init(title: String, @ViewBuilder windowContent: @escaping () -> AnyView, @ViewBuilder statusItemContent: @escaping () -> AnyView) {
        self.mainWindowContentGetter = windowContent
        self.title = title
        super.init()
        
        setupEventMonitors()

        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.isVisible = true

        let siHostingView = NSHostingView(rootView: StatusItemRootView(sizePassthrough: sizePassthrough, mainContent: {
            statusItemContent()
        }))

        statusItem.button?.addSubview(siHostingView)

        siHostingView.translatesAutoresizingMaskIntoConstraints = false
        if let button = statusItem.button {
            NSLayoutConstraint.activate([
                siHostingView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                siHostingView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                siHostingView.leadingAnchor.constraint(equalTo: button.leadingAnchor), // Match the button's width
                siHostingView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                siHostingView.topAnchor.constraint(equalTo: button.topAnchor),         // Match the button's height
                siHostingView.bottomAnchor.constraint(equalTo: button.bottomAnchor)
            ])
        }
        
        self.statusItem = statusItem
        self.statusItemHostingView = siHostingView

        sizeCancellable = sizePassthrough.sink { [weak self] size in
            let frame = NSRect(origin: .zero, size: .init(width: size.width, height: 24))
            self?.statusItemHostingView?.frame = frame
            self?.statusItem?.button?.frame = frame
        }

       
    }
    
    func createMainWindow() {
        
        self.mainWindow?.close()
        self.mainWindow = nil
        
        let window = ModernMenuBarExtraWindow(title: title, content: mainWindowContentGetter)
        self.mainWindow = window
        window.windowManager = self
       
        
        window.delegate = self
       
    }

    deinit {
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    public func destroy() {
        //print("Destroying item")
        mainWindow = nil
        statusItem = nil
    }

    
    public func setStatusItemVisible(_ visible: Bool) {
        
        if let mainWindow {
            
            if !visible && (mainWindowVisible || mainWindow.isVisible) {
                hideStatusItemPending = true
                return
            }
        }
      
        if statusItem.isVisible != visible {
            statusItem.isVisible = visible
        
        }
            
        
        if !visible {
            dismissWindows()
        }
            
       
    }
    
    private func updateStatusItemVisibility() {
        
        
        
    }
    
    func setMonospacedFont() {
        if let button = statusItem.button {
            let currentFontSize = button.font?.pointSize ?? NSFont.systemFontSize
            button.font = NSFont.monospacedDigitSystemFont(ofSize: currentFontSize, weight: .regular)
        }
    }

    public func windowDidBecomeMain(_ notification: Notification) {}

    func setTitle(newTitle: String?) {
        self.statusItem.button?.title = newTitle ?? ""
        DispatchQueue.main.async {
            guard let mainWindow = self.mainWindow else { return }
            self.setWindowPosition(mainWindow)
        }
    }

    func setImage(imageName: String) {
        statusItem.button?.image = NSImage(named: imageName)
    }

    func setImage(systemImageName: String, accessibilityDescription: String? = nil) {
        statusItem.button?.image = NSImage(systemSymbolName: systemImageName, accessibilityDescription: accessibilityDescription)
    }

    private func didPressStatusBarButton(_ sender: NSStatusBarButton) {
        
        windowQueue.sync {
            
            if let mainWindow = mainWindow, mainWindowVisible, mainWindow.isVisible {
                if mainWindowVisible || mainWindow.isVisible {
                    dismissWindows()
                    
                }
            } else {
                setButtonHighlighted(to: true)
                createMainWindow()
                
              
               
                
                // setWindowPosition(mainWindow!)
             
            }
            
        }
    }


    public func windowDidBecomeKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window == mainWindow {
            globalEventMonitor?.start()
            mouseMonitor?.start()
            setButtonHighlighted(to: true)
        }
    }

    public func windowDidResignKey(_ notification: Notification) {
        DispatchQueue.main.async { [self] in
            
            guard let mainWindow else { return }
            
            if !mainWindow.isWindowOrSubwindowKey() {
              
                dismissWindows()
                mainWindowVisible = false
                globalEventMonitor?.stop()
                DistributedNotificationCenter.default().post(name: .endMenuTracking, object: nil)
            }
            
            if hideStatusItemPending {
                hideStatusItemPending = false
                statusItem.isVisible = false
               
            }
            
        }
    }

    private func dismissWindow(window: NSWindow?) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window?.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            window?.close()
            window?.alphaValue = 1

            DistributedNotificationCenter.default().post(name: .endMenuTracking, object: nil)
            if window == self?.mainWindow {
                
                DispatchQueue.main.async {
                   
                    self?.setButtonHighlighted(to: false)
                    self?.mainWindow = nil
                    DistributedNotificationCenter.default().post(name: .endMenuTracking, object: nil)
                }
            }
        }
    }

    private func dismissWindows() {
        
        guard let mainWindow else { return }
        
        mainWindowVisible = false
        
        let all = mainWindow.getSelfAndSubwindows()
        for window in all {
            dismissWindow(window: window)
        }
   
        
    }

    private func setButtonHighlighted(to highlight: Bool) {
        ////print("Set button highlighted: \(highlight)")
        statusItem.button?.highlight(highlight)
    }

    private func setWindowPosition(_ window: NSWindow) {
        guard let statusItemWindow = statusItem.button?.window else {
            window.center()
            return
        }

        var targetRect = statusItemWindow.frame

        if let screen = statusItemWindow.screen {
            let windowWidth = window.frame.width
            if statusItemWindow.frame.origin.x + windowWidth > screen.visibleFrame.width {
                targetRect.origin.x += statusItemWindow.frame.width
                targetRect.origin.x -= windowWidth
                targetRect.origin.x += Metrics.windowBorderSize
            } else {
                targetRect.origin.x -= Metrics.windowBorderSize
            }
        } else {
            targetRect.origin.x -= Metrics.windowBorderSize
        }
        window.setFrameTopLeftPoint(targetRect.origin)
        
        window.makeKeyAndOrderFront(nil)
        mainWindowVisible = true
        DistributedNotificationCenter.default().post(name: .beginMenuTracking, object: nil)
        
    }

    func updateSubwindowPosition(window: ModernMenuBarExtraWindow) {
        guard let parent = window.parent as? ModernMenuBarExtraWindow else { return }
        guard let point = parent.latestSubwindowPoint else { return }

        let subWindowFrame = window.frame
        let mainWindowFrame = parent.frame

        let adjustedPoint = CGPoint(
            x: mainWindowFrame.minX - subWindowFrame.width + 10,
            y: mainWindowFrame.origin.y + mainWindowFrame.height - point.y
        )

        window.setFrameTopLeftPoint(adjustedPoint)
        parent.addChildWindow(window, ordered: .above)
    }

    public func windowDidResize(_ notification: Notification) {
        guard let window = notification.object as? ModernMenuBarExtraWindow else { return }
        
        
        
        if window.isSubwindow {
            
            if window.frame.width < 1 { return }
            
            updateSubwindowPosition(window: window)
        } else if let mainWindow, window == mainWindow {
            
            setWindowPosition(mainWindow)
            
        }
        
    }

    func mouseMoved(event: NSEvent) {
        DispatchQueue.main.async {
            let cursorPosition = NSEvent.mouseLocation
            self.latestCursorPosition = cursorPosition
            self.mainWindow?.mouseMoved(to: cursorPosition)
        }
    }

    public func windowWillClose(_ notification: Notification) {}

    private func setupEventMonitors() {
        localEventMonitor = LocalEventMonitor(mask: [.leftMouseDown]) { [weak self] event in
            guard let self = self else { return event }
            guard let statusItem = self.statusItem else { return event }
            if let button = statusItem.button, event.window == button.window, !event.modifierFlags.contains(.command) {
                self.didPressStatusBarButton(button)
                return nil
            }
            return event
        }

        globalEventMonitor = GlobalEventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self else { return }
            guard let mainWindow else { return }
            if mainWindow.isKeyWindow {
                mainWindow.resignKey()
            }
        }

        mouseMonitor = LocalEventMonitor(mask: [.mouseMoved, .mouseEntered, .mouseExited]) { event in
            self.mouseMoved(event: event)
            return event
        }

        localEventMonitor?.start()
        globalEventMonitor?.start()
        mouseMonitor?.start()
    }
}

public extension Notification.Name {
    static let beginMenuTracking = Notification.Name("com.apple.HIToolbox.beginMenuTrackingNotification")
    static let endMenuTracking = Notification.Name("com.apple.HIToolbox.endMenuTrackingNotification")
}

public enum Metrics {
    static let windowBorderSize: CGFloat = 2
}

public protocol SubwindowDelegate: AnyObject {
    func mouseExitedSubwindow()
}

extension NSWindow {
    func isMouseInside(mouseLocation: NSPoint, tolerance: CGFloat) -> Bool {
        var windowFrame = self.frame
        windowFrame.size.width += tolerance
        let result = windowFrame.contains(mouseLocation)
        return result
    }
}

@MainActor
public protocol SubWindowSelectionManager: AnyObject {
    func setWindowHovering(_ hovering: Bool, id: String?)
    var latestMenuHoverId: String? { get set }
    func mouseMoved(point: NSPoint)
}
