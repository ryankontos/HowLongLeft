//
//  StatusItemManager.swift
//  How Long Left Mac
//
//  Created by Ryan on 24/6/2024.
//

import HowLongLeftKit
import FluidMenuBarExtra
import AppKit

class StatusItemManager {
    
    var menubarExtra: FluidMenuBarExtraWindowManager?
    private let countdown = StatusItemCountdown()
    weak var menuPointStore: TimePointStore?
    weak var statusItemPointStore: TimePointStore?
    
    var custom: String?
    
    private static weak var timer: DispatchSourceTimer?
    
    init(menubarExtra: FluidMenuBarExtraWindowManager, timePointStore: TimePointStore, statusItemPointStore: TimePointStore, customTitle: String?) {
        
        self.custom = customTitle
        
        self.menubarExtra = menubarExtra
        self.menuPointStore = timePointStore
        self.statusItemPointStore = statusItemPointStore
        
        // Immediate initial update
        updateStatusItem()
        
        // Initialize and start the timer
        StatusItemManager.startTimer(with: self)
    }
    
    func destoryMenuItem() {
        
        menubarExtra?.destroy()
        
        menubarExtra = nil
        
    }
    
    deinit {
        menubarExtra?.destroy()
       
    }
    
    func updateStatusItem() {
        
        guard let menubarExtra else { return}
        guard let pointStore = statusItemPointStore else { return}
        
        let now = Date()
        
        
    }
    
    // Start the timer
    private static func startTimer(with manager: StatusItemManager?) {
        weak var weakManager = manager

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)

        // Calculate the initial delay to the start of the next second
        let now = Date()
        let nextSecond = Calendar.current.date(bySetting: .nanosecond, value: 0, of: now)?.addingTimeInterval(-1) ?? now.addingTimeInterval(-1)
        let initialDelay = nextSecond.timeIntervalSince(now)

        timer.schedule(deadline: .now() + initialDelay, repeating: 1.0, leeway: .milliseconds(100))
        timer.setEventHandler {
            weakManager?.updateStatusItem()
        }
        timer.resume()
        StatusItemManager.timer = timer
    }

    
    // Stop the timer
    private static func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}
