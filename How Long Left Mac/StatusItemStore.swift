//
//  StatusItemStore.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/5/2024.
//

import Foundation
import FluidMenuBarExtra
import SwiftUI
import HowLongLeftKit

class StatusItemStore: EventCacheObserver {
    
    var mainManager: StatusItemManager!
    
    var container: MacDefaultContainer

    
    
    init(container: MacDefaultContainer) {
        
        self.container = container
        
        super.init(eventCache: container.eventCache)
        
        
    }
    
    func createMainMenu() {
        
        let model = MainMenuViewModel(timePointStore: self.container.pointStore)
        
        let mainExtra = FluidMenuBarExtra(title: "How Long Left") {
            AnyView(MainMenuContentView(selectionManager: WindowSelectionManager(itemsProvider: model), model: model)
                .environmentObject(self.container.settingsWindow)
                .environmentObject(self.container.pointStore)
                .environmentObject(self.container.calendarReader))
               
        }
        
        
        if let button = mainExtra.statusItem.statusItem.button {
                    // Get the current font size
                    let currentFontSize = button.font?.pointSize ?? NSFont.systemFontSize
                    // Set the button's font to a monospaced digit system font with the existing font size
                    button.font = NSFont.monospacedDigitSystemFont(ofSize: currentFontSize, weight: .regular)
                    
                }
        
        
        let statusItemPointStore = TimePointStore(eventCache: self.container.statusItemEventFilter)
        
        self.mainManager = StatusItemManager(menubarExtra: mainExtra, timePointStore: statusItemPointStore)
       
        
    }
    
    override func eventsChanged() {
        if mainManager == nil && container.calendarReader.authorization != .notDetermined {
            createMainMenu()
        }
    }
    
}


import Foundation

class StatusItemManager {
    
    private let menubarExtra: FluidMenuBarExtra
    private let countdown = StatusItemCountdown()
    private let pointStore: TimePointStore
    
    private static var timer: DispatchSourceTimer?
    
    init(menubarExtra: FluidMenuBarExtra, timePointStore: TimePointStore) {
        self.menubarExtra = menubarExtra
        self.pointStore = timePointStore
        
        // Immediate initial update
        updateStatusItem()
        
        // Initialize and start the timer
        StatusItemManager.startTimer(with: self)
    }
    
    deinit {
        // Invalidate the timer when the instance is deallocated
        StatusItemManager.stopTimer()
    }
    
    func updateStatusItem() {
        let now = Date()
        
        if let event = pointStore.getPointAt(date: now)?.fetchSingleEvent(accordingTo: .soonestCountdownDate) {
            let string = StatusItemCountdown.countdownString(for: event)
            self.menubarExtra.statusItem.statusItem.button?.title = string
            self.menubarExtra.statusItem.statusItem.button?.image = nil
        } else {
            self.menubarExtra.statusItem.statusItem.button?.title = ""
            self.menubarExtra.statusItem.statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
        }
    }
    
    // Start the timer
    private static func startTimer(with manager: StatusItemManager) {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        
        // Calculate the initial delay to the start of the next second
        let now = Date()
        let nextSecond = Calendar.current.date(bySetting: .nanosecond, value: 0, of: now)?.addingTimeInterval(-1) ?? now.addingTimeInterval(-1)
        let initialDelay = nextSecond.timeIntervalSince(now)
        
        timer.schedule(deadline: .now() + initialDelay, repeating: 1.0, leeway: .milliseconds(100))
        timer.setEventHandler {
            manager.updateStatusItem()
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

