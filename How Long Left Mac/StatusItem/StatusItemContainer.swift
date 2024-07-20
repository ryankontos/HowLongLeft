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

class StatusItemContainer: Identifiable, ObservableObject, Hashable {
    
    let id: String
    let hiddenEventManager: StoredEventManager
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
    var statusItemSettings: StatusItemSettings?
    
    var menubarExtra: FluidMenuBarExtraWindowManager?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        source: CalendarSource,
        hiddenEventManager: StoredEventManager,
        info: StatusItemConfiguration,
        settings: StatusItemSettings,
        settingsWindow: SettingsWindow,
        timer: GlobalTimerContainer,
        listManager: EventListSettingsManager,
        filtering: EventFetchSettingsManager
    ) {
        self.source = source
        self.id = info.identifier!
        self.info = info
        self.settingsWindow = settingsWindow
        self.timer = timer
        self.hiddenEventManager = hiddenEventManager
        self.listManager = listManager
      
        self.filtering = filtering
        
        self.menuCache = EventCache(
            calendarReader: source,
            calendarProvider: filtering,
            calendarContexts: [HLLStandardCalendarContexts.app.rawValue],
            hiddenEventManager: hiddenEventManager, id: "StatusItemContainer_MenuCache_\(info.identifier!)")
        
        
        self.statusItemCache = EventCache(
            calendarReader: source,
            calendarProvider: filtering,
            calendarContexts: [MacCalendarContexts.statusItem.rawValue],
            hiddenEventManager: hiddenEventManager, id: "StatusItemContainer_StatusItemCache_\(info.identifier!)")
        
        
        self.pointStore = TimePointStore(eventCache: menuCache)
        self.statusItemPointStore = TimePointStore(eventCache: statusItemCache)
        self.infoObject = MenuConfigurationInfo(info: info, settings: nil)
        
        setupFilteringObservation()
        checkActivation()
    }
    
    func setSettings(to: StatusItemSettings) {
        
        self.statusItemSettings = to
        
    }
    
    private func setupFilteringObservation() {
        filtering?.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func checkActivation() {
        
        guard info.activated else { return }
        
        guard self.menubarExtra == nil else { return }
        
        let model = MainMenuViewModel(timePointStore: pointStore, listSettings: listManager)
        
        let extra = FluidMenuBarExtraWindowManager(
            title: "\(info.title!)",
            windowContent: { [self] in
                
                AnyView(MainMenuContentView(selectionManager: WindowSelectionManager(itemsProvider: model), model: model)
                    .environmentObject(hiddenEventManager)
                    .environmentObject(listManager)
                    .environmentObject(settingsWindow)
                    .environmentObject(pointStore)
                    .environmentObject(source)
                    .environmentObject(timer)
                    .environmentObject(infoObject))
            },
            statusItemContent: { [self] in
                AnyView(StatusItemContentView()
                    .environmentObject(statusItemPointStore)
                    .environmentObject(infoObject)
                    .environmentObject(statusItemSettings!))
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
