//
//  CustomStatusItemContainer.swift
//  How Long Left Mac
//
//  Created by Ryan on 24/6/2024.
//

import Foundation
import HowLongLeftKit
import Combine
import FluidMenuBarExtra
import AppKit
import SwiftUI

@MainActor
class StatusItemContainer: Identifiable, ObservableObject, Hashable {
    
    let id: String
    let hiddenEventManager: StoredEventManager
    let selectedEventManager: StoredEventManager
    let settingsWindow: SettingsWindow
    let timer: GlobalTimerContainer
    let info: StatusItemConfiguration
    let pointStore: TimePointStore
    let statusItemPointStore: TimePointStore
    let source: CalendarSource
    let menuCache: EventCache
    let statusItemCache: EventCache
    let filtering: EventFetchSettingsManager?
    let listManager: EventListSettingsManager
    var infoObject: MenuConfigurationInfo
    var statusItemSettings: StatusItemSettings
    let config: StatusItemConfiguration?
    var menubarExtra: FluidMenuBarExtraWindowManager?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        source: CalendarSource,
        hiddenEventManager: StoredEventManager,
        selectedManager: StoredEventManager,
        info: StatusItemConfiguration,
        settings: StatusItemSettings,
        settingsWindow: SettingsWindow,
        timer: GlobalTimerContainer,
        listManager: EventListSettingsManager,
        filtering: EventFetchSettingsManager,
        config: StatusItemConfiguration?
    ) {
        self.config = config
        self.source = source
        self.id = info.identifier!
        self.info = info
        self.settingsWindow = settingsWindow
        self.timer = timer
        self.hiddenEventManager = hiddenEventManager
        self.selectedEventManager = selectedManager
        self.listManager = listManager
        self.statusItemSettings = settings
        self.filtering = filtering
        
        self.menuCache = EventCache(
            calendarReader: source,
            calendarProvider: filtering,
            calendarContexts: [HLLStandardCalendarContexts.app.rawValue],
            hiddenEventManager: hiddenEventManager, id: "StatusItemContainer_MenuCache_\(info.identifier!)")
        
        
        self.statusItemCache = EventCache(
            calendarReader: source,
            calendarProvider: filtering,
            calendarContexts: [MacCalendarContexts.statusItem.rawValue, HLLStandardCalendarContexts.app.rawValue],
            hiddenEventManager: hiddenEventManager, id: "StatusItemContainer_StatusItemCache_\(info.identifier!)")
        
        
        self.pointStore = TimePointStore(eventCache: menuCache)
        self.statusItemPointStore = TimePointStore(eventCache: statusItemCache)
        self.infoObject = MenuConfigurationInfo(info: info, settings: nil)
        
        setupFilteringObservation()
        setupStatusItemPointStoreObservation()
        checkActivation()
        evaluateVisibility()
    }
    
    func setSettings(to: StatusItemSettings) {
        
        self.statusItemSettings = to
        
    }
    
    private func setupStatusItemPointStoreObservation() {
        statusItemPointStore.objectWillChange
            .sink { [weak self] _ in
                self?.evaluateVisibility()
            }
            .store(in: &cancellables)
    }
    
    
    private func setupFilteringObservation() {
        filtering?.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func evaluateVisibility() {
        

        
        guard let currentPoint = statusItemPointStore.currentPoint else { return }
        
        let event = currentPoint.fetchSingleEvent(accordingTo: .preferInProgress)
     
        //menubarExtra?.setStatusItemVisible(event != nil)
        
    }
    
    func checkActivation() {
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        
        guard info.activated else { return }
        
        guard self.menubarExtra == nil else { return }
        
        let model = MainMenuViewModel(timePointStore: pointStore, listSettings: listManager, selectedManager: selectedEventManager)
        
        let extra = FluidMenuBarExtraWindowManager(
            title: "\(info.title!)",
            windowContent: { [self] in
                
                AnyView(MainMenuContentView(selectedManager: selectedEventManager, selectionManager: WindowSelectionManager(itemsProvider: model), model: model)
                    .environmentObject(hiddenEventManager)
                    .environmentObject(listManager)
                    .environmentObject(settingsWindow)
                    .environmentObject(pointStore)
                    .environmentObject(source)
                    .environmentObject(timer)
                    .environmentObject(infoObject))
            },
            statusItemContent: { [self] in
                AnyView(StatusItemContentView(selectedManager: selectedEventManager)
                    .environmentObject(statusItemPointStore)
                    .environmentObject(infoObject)
                    .environmentObject(statusItemSettings)
                    .environmentObject(source)
                )
            }
        )
        
        self.menubarExtra = extra
    }
    
    func getCalendarsDescription() -> String {
        guard let filtering else { return "" }
        
        let statusItemContext = Set([MacCalendarContexts.statusItem.rawValue])
        let menuContext = Set([MacCalendarContexts.menu.rawValue])
        
        let allAllowed = filtering.getAllowedCalendars(matchingContextIn: statusItemContext)
        let onlyMenu = filtering.getAllowedCalendars(matchingContextIn: menuContext)
        
        return "All: \(allAllowed.count), Menu Only: \(onlyMenu.count)"
    }
    
    func destroy() {
        self.menubarExtra?.destroy()
    }
    
    static func == (lhs: StatusItemContainer, rhs: StatusItemContainer) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    deinit {
        print("Deinit CustomStatusItemContainer")
    }
}
