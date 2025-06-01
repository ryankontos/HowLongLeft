//
//  ModernMenuBarExtraWindow.swift
//  FluidMenuBarExtra
//
//  Created by Lukas Romsicki on 2022-12-16.
//  Copyright © 2022 Lukas Romsicki.
//
import AppKit
import SwiftUI
import Combine
import os.log

/// A custom window configured to behave as closely to an `NSMenu` as possible.
/// `ModernMenuBarExtraWindow` listens for changes to the size of its content and
/// automatically adjusts its frame to match.
public class ModernMenuBarExtraWindow: NSPanel, NSWindowDelegate, ObservableObject {
    
    // MARK: - Properties
    
    let logger: Logger
    private var isDragging = false
    
    public var subWindow: ModernMenuBarExtraWindow?
    public var currentHoverId: String?
    public weak var hoverManager: SubWindowSelectionManager?
    
    private var mainWindowVisible = false
    private var subwindowID = UUID()
    private var openSubwindowWorkItem: DispatchWorkItem?
    private var closeSubwindowWorkItem: DispatchWorkItem?
    
    private var subwindowViews = [String: AnyView]()
    private var subwindowPositions = [String: CGPoint]()
    
    public var latestSubwindowPoint: CGPoint?
    private var subwindowHovering = false
    
    public var proxy: FMBEWindowProxy! = FMBEWindowProxy()
    
    public let isSubwindow: Bool
    @Published var mouseHovering = false
    
    public var resizeMode: ResizeMode = .windowDriven
    public var setPosition = false
    public var isResized = false
    
    public weak var windowManager: FluidMenuBarExtraWindowManager?
    
    var resize = true {
        didSet {
            if let latestCGSize = self.latestCGSize, self.resize {
                self.contentSizeDidUpdate(to: latestCGSize)
            }
        }
    }
    
    var isSecondary = false {
        didSet {
            self.level = isSecondary ? .popUpMenu : .normal
        }
    }
    
    var isDetached = false {
        didSet {
            // When entering detached mode
            if isDetached {
                self.showCloseButton()
                animateToLargeSize()
                hoverManager = nil
                playHapticFeedbackOnDetached()
                proxy.isAttached = false
            }
        }
    }
    
    var latestCGSize: CGSize?
    private var content: () -> AnyView
    
    private lazy var visualEffectView: NSVisualEffectView = {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .popover
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }()
    
    private var rootView: AnyView {
        AnyView(
            content()
                .environmentObject(self.proxy)
                .modifier(RootViewModifier(windowTitle: title))
                .onSizeUpdate { [weak self] size in
                    self?.latestCGSize = size
                    if self?.resize ?? true {
                        self?.contentSizeDidUpdate(to: size)
                    }
                }
        )
    }
    
    private var hostingView: NSHostingView<AnyView>!
    
    // MARK: - Initializer
    
    public init(contentRect: CGRect? = nil, title: String, isSubWindow isSub: Bool = false, content: @escaping () -> AnyView) {
        self.content = content
        self.isSubwindow = isSub
        
        self.logger = Logger(subsystem: "com.ryankontos.fluid-menu-bar-extra", category: "ModernMenuBarExtraWindow-\(title)")
        
        super.init(
            contentRect: contentRect ?? CGRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.titled, .nonactivatingPanel, .utilityWindow, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.proxy?.window = self
        
        self.isReleasedWhenClosed = false
        self.title = title
        self.delegate = self
        configureWindow()
        setupHostingView()
        visualEffectView.addSubview(hostingView)
        setContentSize(hostingView.intrinsicContentSize)
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    
    
    
    private func configureWindow() {
        isMovable = false
        isMovableByWindowBackground = false
        //isFloatingPanel = true
        level = .modalPanel
        isOpaque = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        animationBehavior = .none
        
        
        
        if #available(macOS 13.0, *) {
            collectionBehavior = [.fullScreenAllowsTiling, .fullScreenPrimary, .auxiliary, .ignoresCycle, .stationary]
        } else {
            collectionBehavior = [.stationary, .moveToActiveSpace, .fullScreenAuxiliary]
        }
        
        hidesOnDeactivate = false
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        contentView = visualEffectView
    }
    
    private func setupHostingView() {
        hostingView = NSHostingView(rootView: rootView)
        if #available(macOS 13.0, *) {
            hostingView.sizingOptions = []
        }
        hostingView.isVerticalContentSizeConstraintActive = false
        hostingView.isHorizontalContentSizeConstraintActive = false
        hostingView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor)
        ])
    }
    
    // MARK: - Content Update Methods
    
    public func updateContent(to newContent: AnyView) {
        hostingView.removeFromSuperview()
        self.content = { newContent }
        setupHostingView()
        visualEffectView.addSubview(hostingView)
        setContentSize(hostingView.intrinsicContentSize)
        setupConstraints()
    }
    
    // MARK: - Size Management
    
    public func resizeBasedOnLastSize() {
        if let latestCGSize = self.latestCGSize {
            self.contentSizeDidUpdate(to: latestCGSize)
        }
    }
    
    public func contentSizeDidUpdate(to size: CGSize) {
        var nextFrame = frame
        
        if !isDetached {
            let previousContentSize = contentRect(forFrameRect: frame).size
            let deltaX = size.width - previousContentSize.width
            let deltaY = size.height - previousContentSize.height
            
            nextFrame.origin.y -= deltaY
            nextFrame.size.width += deltaX
            nextFrame.size.height += deltaY
            
            guard frame != nextFrame else { return }
            
            
            
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.setFrame(nextFrame, display: false, animate: false)
            self?.setPosition = true
        }
            
           
            
        
    }
    
    // MARK: - Subwindow Management
    
    public func openSubWindow(id: String) {
        
       
        
        if let subWindow = self.subWindow, subWindow.isVisible && subWindow.title == id {
            //print("Subwindow already open")
            return
        }
        
        closeSubwindowWorkItem?.cancel()
        openSubwindowWorkItem?.cancel()
        
        var possibleItem: DispatchWorkItem?
        let item = DispatchWorkItem { [weak self] in
            
            //print("Opening subwindow")
            
            guard let self = self, let view = self.subwindowViews[id], let pos = self.subwindowPositions[id] else {
                
                //print("Failed to open subwindow")
                return }
            if let possibleItem = possibleItem, possibleItem.isCancelled {
                
                //print("Cancelled")
                return }
            
            self.latestSubwindowPoint = pos
            self.subWindow?.close()
            
            self.subWindow = ModernMenuBarExtraWindow(title: id, isSubWindow: true, content: { AnyView(view) })
            self.addChildWindow(self.subWindow!, ordered: .above)
            
            self.subWindow?.isReleasedWhenClosed = false
            self.subWindow?.delegate = self.delegate
            self.subWindow?.windowManager = self.windowManager
            
            if !(possibleItem?.isCancelled ?? false) {
                self.subWindow = self.subWindow
                self.currentHoverId = id
                self.subwindowID = UUID()
                
                self.subWindow?.orderFrontRegardless()
            }
        }
        
        possibleItem = item
        self.openSubwindowWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: item)
    }
    
    public func registerSubwindowView(view: AnyView, for id: String) {
        subwindowViews[id] = view
    }
    
    public func registerSubwindowButtonPosition(point: CGPoint, for id: String) {
        subwindowPositions[id] = point
        
        
    }
    
    override public func close() {
        guard !isDetached else { return }
        closeSubwindow()
        subwindowViews.removeAll()
        subwindowPositions.removeAll()
        super.close()
    }
    
    public func closeSubwindow(notify: Bool = true) {
        
       // //print("Closing subwindow")
        
        
        
        guard !isDetached else { return }
        let id = subwindowID
       
        openSubwindowWorkItem?.cancel()
        
        let item = DispatchWorkItem { [weak self] in
            if id != self?.subwindowID { return }
            if !(self?.subwindowHovering ?? false) {
                if notify {
                    self?.hoverManager?.setWindowHovering(false, id: self?.currentHoverId)
                }
                self?.subWindow?.orderOut(nil)
                self?.subWindow?.close()
                self?.subWindow = nil
            }
        }
        
        closeSubwindowWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: item)
    }
    
    // MARK: - Mouse Handling
    
    func mouseMoved(to cursorPosition: NSPoint) {
        
        guard !isDetached else { return }
        
        hoverManager?.mouseMoved(point: cursorPosition)
        
        let cursorInSelf = self.isMouseInside(mouseLocation: cursorPosition, tolerance: 2)
        
        if cursorInSelf {
            activateWindow()
        }
        
        if let window = self.subWindow {
            subwindowHovering = window.isCursorInSelfOrSubwindows(cursorPosition: cursorPosition)
            if subwindowHovering {
                setForceHover(true)
                closeSubwindowWorkItem?.cancel()
            }
        }
        
        subWindow?.mouseMoved(to: cursorPosition)
    }
    
    func setForceHover(_ force: Bool) {
        hoverManager?.setWindowHovering(force, id: currentHoverId)
    }
    
    func isWindowOrSubwindowKey() -> Bool {
        if let subWindow, subWindow.isWindowOrSubwindowKey() {
            return true
        }
        return self.isKeyWindow && self.isVisible
    }
    
    public func windowWillClose(_ notification: Notification) {}
    
    func isCursorInSelfOrSubwindows(cursorPosition: NSPoint) -> Bool {
        
        if isDetached { return true }
        
        if isMouseInside(mouseLocation: cursorPosition, tolerance: 0) {
            activateWindow()
            return true
        }
        if let subWindow, subWindow.isCursorInSelfOrSubwindows(cursorPosition: cursorPosition) {
            return true
        }
        return false
    }
    
    func getSelfAndSubwindows() -> [ModernMenuBarExtraWindow] {
        var result = [self]
        var current: ModernMenuBarExtraWindow? = self
        while let nextWindow = current, let subwindow = nextWindow.subWindow {
            result.append(subwindow)
            current = subwindow
        }
        return result
    }
    
    func activateWindow() {
        if !self.isKeyWindow {
            self.makeKey()
            self.makeFirstResponder(self)
            self.setForceHover(false)
        }
    }
    
    private func showCloseButton() {
        
        //print("Showing close button")
        
        NSApp.activate(ignoringOtherApps: true)
        
        self.styleMask.insert([.titled, .resizable, .closable, .miniaturizable])
        self.styleMask.remove([.utilityWindow, .nonactivatingPanel, .fullSizeContentView])
        
        
        self.hidesOnDeactivate = false
        
       // self.isFloatingPanel = false
        titleVisibility = .visible
        standardWindowButton(.closeButton)?.isHidden = false
        standardWindowButton(.miniaturizeButton)?.isHidden = false

        self.level = .normal
        
       
        self.makeKeyAndOrderFront(self)
        self.makeFirstResponder(self)
        
        resizeMode = .windowDriven
        
        
        self.delegate = nil
       
        NSApp.activate(ignoringOtherApps: true)
    }
    
   
    
    private func playHapticFeedbackOnDetached() {
        let generator = NSHapticFeedbackManager.defaultPerformer
        generator.perform(.alignment, performanceTime: .default)
    }
    
    private func animateToLargeSize() {
        guard !isResized else { return }
        guard isDetached else { return }
        guard !isDragging else { return }
        
        isResized = true
        let targetSize = CGSize(width: 620, height: 370)
        let animationDuration: TimeInterval = 0.3
        
        guard frame.size != targetSize else { return }
        
        var newFrame = frame
        newFrame.size = targetSize
        newFrame.origin.y -= targetSize.height - frame.height
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animator().setFrame(newFrame, display: true)
        }
    }
    
    deinit {
        self.proxy = nil
    }
    
    override public func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        isDragging = true
    }
    
    override public func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        isDragging = false
        animateToLargeSize()
    }
}

public class FMBEWindowProxy: ObservableObject {
    @Published public var isAttached = true
    weak public var window: ModernMenuBarExtraWindow?
}

public enum ResizeMode {
    case contentDriven // Window resizes to match the SwiftUI content
    case windowDriven  // SwiftUI content fits within the window
}

public class MainableNSPanel: NSPanel {
    
    override public var canBecomeMain: Bool {
        return true
        
    }
    
}
