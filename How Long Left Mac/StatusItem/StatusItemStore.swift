//
//  StatusItemStore.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/5/2024.
//

import Combine
import FluidMenuBarExtra
import HowLongLeftKit
import SwiftUI

class StatusItemStore: EventCacheObserver, ObservableObject {
    var defaultContainer: MacDefaultContainer

    @Published var mainStatusItemContainer: StatusItemContainer?
    @Published var customStatusItemContainers = Set<StatusItemContainer>()
    private var cancellables: Set<AnyCancellable> = []

    private var customItemStoreSubscription: AnyCancellable?

    let statusItemDataStore = StatusItemConfigurationStore()
    let settingsStore = StatusItemSettingsStore()

    init(container: MacDefaultContainer) {
        self.defaultContainer = container
        super.init(eventCache: container.eventCache)
    }

    @MainActor
    func createNewCustomStatusItem() -> StatusItemContainer {
        let newInfo = statusItemDataStore.makeNewCustomStatusItem()
        let container = initalizeCustomStatusItemContainer(from: newInfo)
        customStatusItemContainers.insert(container)
        updateSubscriptions()
        return container
    }

    @MainActor
    func loadMainStatusItem() {
        guard mainStatusItemContainer == nil else { return }
        let info = statusItemDataStore.getMainStatusItem()
        mainStatusItemContainer = initalizeCustomStatusItemContainer(from: info)
        mainStatusItemContainer?.setSettings(newValue: getSettings(info: info))
    }

    @MainActor
    func loadCustomStatusItemContainers() {
        
        var newContainers = Set<StatusItemContainer>()
        let existing = customStatusItemContainers
        let newInfos = statusItemDataStore.getCustomStatusItems()

        // Add existing items that are still relevant
        for existingItem in existing where newInfos.contains(where: { $0.identifier == existingItem.info.identifier }) {
            newContainers.insert(existingItem)
        }

        // Add new items that are not already in newContainers
        for info in newInfos where !newContainers.contains(where: { $0.info.identifier == info.identifier }) {
            newContainers.insert(initalizeCustomStatusItemContainer(from: info))
        }

        // Destroy items that are in the original set but not in the new set
        for existingItem in existing where !newContainers.contains(existingItem) {
            existingItem.destroy()
        }

        newContainers.forEach { container in
            container.setSettings(newValue: getSettings(info: container.info))
        }

       // print("Finished loading containers, there are now \(newContainers.count)")
        self.customStatusItemContainers = newContainers
        updateSubscriptions()
    }

    @MainActor
    private func initalizeCustomStatusItemContainer(from info: StatusItemConfiguration) -> StatusItemContainer {
        var filtering = defaultContainer.calendarPrefsManager

        if info.isCustom {
            let appSet: Set<String> = []
            let config = EventFetchSettingsManager.Configuration(
                domain: "HLLMac_CustomStatusItem_\(info.identifier!)",
                defaultContextsForNonMatches: appSet)

            filtering = EventFetchSettingsManager(calendarSource: defaultContainer.calendarReader, config: config)
        }

        return StatusItemContainer(
            source: defaultContainer.calendarReader,
            hiddenEventManager: defaultContainer.hiddenEventManager,
            selectedManager: defaultContainer.selectedEventManager,
            info: info,
            settings: getSettings(info: info),
            settingsWindow: defaultContainer.settingsWindow,
            eventWindowManager: defaultContainer.eventWindowManager!,
            timer: defaultContainer.timerContainer,
            listManager: defaultContainer.eventListSettingsManager,
            filtering: filtering,
            config: info)
    }

    @MainActor

    private func updateSubscriptions() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        customStatusItemContainers.forEach { container in
            container.objectWillChange
                .sink { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.customStatusItemContainerDidChange(container)
                    }
                }
                .store(in: &cancellables)
        }
    }

    @MainActor
    private func setUpCustomItemStoreSubscription() {
        self.customItemStoreSubscription?.cancel()
        self.customItemStoreSubscription = nil

        self.customItemStoreSubscription = statusItemDataStore.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.loadCustomStatusItemContainers()
                    self?.objectWillChange.send()
                }
            }
    }

    @MainActor private func customStatusItemContainerDidChange(_: StatusItemContainer) {
        // Handle the change and update the array if necessary
        loadCustomStatusItemContainers()
        objectWillChange.send()
    }

    private func getSettings(info: StatusItemConfiguration) -> StatusItemSettings {
        if info.isCustom && info.useDefaultSettings {
            return settingsStore.getSettings(withId: info.identifier!)
        }
        return settingsStore.getDefaultSettings()
    }

    override func eventsChanged() {
        DispatchQueue.main.async { [self] in
            if defaultContainer.calendarReader.authorization != .notDetermined {
                setUpCustomItemStoreSubscription()
                loadMainStatusItem()
                loadCustomStatusItemContainers()
            }
        }
    }
}
