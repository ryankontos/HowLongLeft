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

class CustomStatusItemContainer: Identifiable, ObservableObject, Hashable {
    static func == (lhs: CustomStatusItemContainer, rhs: CustomStatusItemContainer) -> Bool {
        return lhs.id == rhs.id
        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    
    private var cancellables: Set<AnyCancellable> = []
    let id: UUID
    var statusItem: StatusItemManager?
    
    let hiddenEventManager: StoredEventManager
    let settings: SettingsWindow
    let timer: GlobalTimerContainer
    let info: CustomStatusItemInfo
    let pointStore: TimePointStore
    let statusItemPointStore: TimePointStore
    let source: CalendarSource
    let menuCache: EventCache
    let statusItemCache: EventCache
    let filtering: EventFetchSettingsManager?
    let listManager: EventListSettingsManager
    var infoObject: MenuConfigurationInfo
    
    init(source: CalendarSource, hiddenEventManager: StoredEventManager, info: CustomStatusItemInfo, settings: SettingsWindow, timer: GlobalTimerContainer, listManager: EventListSettingsManager) {
        self.source = source
        self.id = info.identifier!
        
        let appSet: Set<String> = []
        let config = EventFetchSettingsManager.Configuration(domain: "HLLMac_CustomStatusItem_\(info.identifier!)", defaultContextsForNonMatches: appSet)
        
        self.filtering = EventFetchSettingsManager(calendarSource: source, config: config)
        
        menuCache = EventCache(calendarReader: source, calendarProvider: filtering!, calendarContexts: [HLLStandardCalendarContexts.app.rawValue], hiddenEventManager: hiddenEventManager)
        
        statusItemCache = EventCache(calendarReader: source, calendarProvider: filtering!, calendarContexts: [MacCalendarContexts.statusItem.rawValue], hiddenEventManager: hiddenEventManager)
        
        pointStore = TimePointStore(eventCache: menuCache)
        statusItemPointStore = TimePointStore(eventCache: statusItemCache)
        
        self.listManager = listManager
        self.info = info
        self.settings = settings
        self.timer = timer
        
        self.infoObject = MenuConfigurationInfo(info: info)
        
        self.hiddenEventManager = hiddenEventManager
        
        setupFilteringObservation()
        
        checkActivation()
    }
    
    func checkActivation() {
        
        guard info.activated else { return }
        
        let model = MainMenuViewModel(timePointStore: self.pointStore, listSettings: self.listManager)
        
        
        let extra = FluidMenuBarExtraWindowManager(title: "\(info.title!)", windowContent: {
            AnyView(MainMenuContentView(selectionManager: WindowSelectionManager(itemsProvider: model), model: model)
                .environmentObject(self.hiddenEventManager)
                .environmentObject(self.listManager)
                .environmentObject(self.settings)
                .environmentObject(self.pointStore)
                .environmentObject(self.source)
                .environmentObject(self.timer)
                .environmentObject(self.infoObject))
        }, statusItemContent: {
            AnyView(
                
                StatusItemContentView()
                    .environmentObject(self.statusItemPointStore)
                    .environmentObject(self.infoObject)
            
            )
        })
        
        
        
       
        
        self.statusItem = StatusItemManager(menubarExtra: extra, timePointStore: pointStore, statusItemPointStore: statusItemPointStore, customTitle: info.title)
    }
    
    private func setupFilteringObservation() {
        filtering?.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func getCalendarsDescription() -> String {
        
        guard let filtering else { return "" }
        
        let statusItemContext = Set([MacCalendarContexts.statusItem.rawValue])
        let menuContext = Set([MacCalendarContexts.menu.rawValue])
        
        let allAllowed = filtering.getAllowedCalendars(matchingContextIn: statusItemContext)
        let onlyMenu = filtering.getAllowedCalendars(matchingContextIn: menuContext)
        
        return "All: \(allAllowed.count), Menu Only: \(onlyMenu.count)"
    }
    
    deinit {
        print("Deinit CustomStatusItemContainer")
    }
}
