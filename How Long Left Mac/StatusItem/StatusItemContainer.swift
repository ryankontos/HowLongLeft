//
//  CustomStatusItemContainer.swift
//  How Long Left Mac
//
//  Created by Ryan on 24/6/2024.
//

import AppKit
import Combine
import FluidMenuBarExtra
import Foundation
import HowLongLeftKit
import SwiftUI

@MainActor
final public class StatusItemContainer: @preconcurrency Identifiable, ObservableObject, @preconcurrency Hashable {
    public let id: String
    let hiddenEventManager: StoredEventManager
    let selectedEventManager: StoredEventManager
    let settingsWindow: SettingsWindow
    let timer: GlobalTimerContainer
    let info: StatusItemConfiguration
    let pointStore: TimePointStore
    let statusItemPointStore: TimePointStore
    let source: CalendarSource
    let menuCache: CalendarEventCache
    let statusItemCache: CalendarEventCache
    let filtering: CalendarSettingsStore?
    let listManager: EventListSettingsManager
    var infoObject: MenuConfigurationInfo
    var statusItemSettings: StatusItemSettings
    let config: StatusItemConfiguration?
    var menubarExtra: FluidMenuBarExtraWindowManager?
    let eventWindowManager: EventWindowManager
    let eventProvider: StatusItemEventProvider
    var forceVisible = false {
        didSet {
            evaluateVisibility()
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []

    init(
        source: CalendarSource,
        hiddenEventManager: StoredEventManager,
        selectedManager: StoredEventManager,
        info: StatusItemConfiguration,
        settings: StatusItemSettings,
        settingsWindow: SettingsWindow,
        eventWindowManager: EventWindowManager,
        timer: GlobalTimerContainer,
        listManager: EventListSettingsManager,
        filtering: CalendarSettingsStore,
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
        self.eventWindowManager = eventWindowManager

        self.menuCache = CalendarEventCache(
            calendarReader: source,
            calendarProvider: filtering,
            calendarContexts: [HLLStandardCalendarContexts.app.rawValue],
            hiddenEventManager: hiddenEventManager, id: "StatusItemContainer_MenuCache_\(info.identifier!)")

        self.statusItemCache = CalendarEventCache(
            calendarReader: source,
            calendarProvider: filtering,
            calendarContexts: [MacCalendarContexts.statusItem.rawValue, HLLStandardCalendarContexts.app.rawValue],
            hiddenEventManager: hiddenEventManager, id: "StatusItemContainer_StatusItemCache_\(info.identifier!)")

        self.pointStore = TimePointStore(eventCache: menuCache)
        self.statusItemPointStore = TimePointStore(eventCache: statusItemCache)
        self.infoObject = MenuConfigurationInfo(info: info, settings: nil)

        self.eventProvider = StatusItemEventProvider(pointStore: statusItemPointStore, selectedManager: selectedEventManager, settings: settings)
        
        setupFilteringObservation()
        setupStatusItemPointStoreObservation()
        setupStatusItemSettingsObservation()

        checkActivation()
        evaluateVisibility()
        
    }

    func setSettings(newValue: StatusItemSettings) {
        self.statusItemSettings = newValue
    }

    private func setupStatusItemPointStoreObservation() {
        statusItemPointStore.objectWillChange
            .sink { [weak self] _ in
                Task {
                    self?.evaluateVisibility()
                }
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
    
    private func setupStatusItemSettingsObservation() {
        statusItemSettings.objectWillChange
            .sink { [weak self] _ in
                Task {
                    self?.evaluateVisibility()
                }
            }
            .store(in: &cancellables)
    }

    func evaluateVisibility() {

        guard statusItemSettings.hidesWhenEmpty && !forceVisible else {
            menubarExtra?.setStatusItemVisible(true)
            return
        }
        
      //  //print("Evaluating visibility for \(info.title!)")
        
        let eventExists = eventProvider.getEvent(at: Date()) != nil
        
       // //print("Event exists: \(eventExists)")
        
        menubarExtra?.setStatusItemVisible(true)
        
    }

    @MainActor func checkActivation() {
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }

        guard info.activated else { return }

        guard self.menubarExtra == nil else { return }

        let model = MainMenuViewModel(timePointStore: pointStore, listSettings: listManager, selectedManager: selectedEventManager)
        
        let extra = FluidMenuBarExtraWindowManager(
            title: "\(info.title!)",
            windowContent: { [self] in
                AnyView(MainMenuContentView(statusItemPointStore: statusItemPointStore, selectedManager: selectedEventManager, selectionManager: WindowSelectionManager(itemsProvider: model), model: model)
                            .environmentObject(hiddenEventManager)
                            .environmentObject(listManager)
                            .environmentObject(settingsWindow)
                            .environmentObject(pointStore)
                            .environmentObject(source)
                            .environmentObject(timer)
                            .environmentObject(infoObject)
                            .environmentObject(eventWindowManager)
                )
            },
            statusItemContent: { [self] in
                AnyView(StatusItemContentView(selectedManager: selectedEventManager, eventProvider: eventProvider)
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

    @MainActor
    func destroy() {
        self.menubarExtra?.destroy()
    }

    static public func == (lhs: StatusItemContainer, rhs: StatusItemContainer) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    deinit {
        //print("Deinit CustomStatusItemContainer")
    }
}
