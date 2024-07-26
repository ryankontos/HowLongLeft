//
//  StatusItemStore.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/5/2024.
//

import FluidMenuBarExtra
import HowLongLeftKit
import Combine
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
    
    func createNewCustomStatusItem() -> StatusItemContainer {
        let newInfo = statusItemDataStore.makeNewCustomStatusItem()
        let container = initalizeCustomStatusItemContainer(from: newInfo)
        customStatusItemContainers.insert(container)
        updateSubscriptions()
        return container
    }
    
    func loadMainStatusItem() {
        guard mainStatusItemContainer == nil else { return }
        let info = statusItemDataStore.getMainStatusItem()
        mainStatusItemContainer = initalizeCustomStatusItemContainer(from: info)
        mainStatusItemContainer?.setSettings(to: getSettings(info: info))
    }
    
    func loadCustomStatusItemContainers() {
        
        print("Loading containers, there are currently \(self.customStatusItemContainers.count)")
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
            container.setSettings(to: getSettings(info: container.info))
        }
        
        print("Finished loading containers, there are now \(newContainers.count)")
        self.customStatusItemContainers = newContainers
        updateSubscriptions()
    }
    
    private func initalizeCustomStatusItemContainer(from info: StatusItemConfiguration) -> StatusItemContainer {
        
        
        var filtering = defaultContainer.calendarPrefsManager
        
        if info.isCustom {
            let appSet: Set<String> = []
            let config = EventFetchSettingsManager.Configuration(
                domain: "HLLMac_CustomStatusItem_\(info.identifier!)",
                defaultContextsForNonMatches: appSet)
            
                filtering = EventFetchSettingsManager(calendarSource: defaultContainer.calendarReader, config: config)
            
        }
        
      
         
        return StatusItemContainer(source: defaultContainer.calendarReader, hiddenEventManager: defaultContainer.hiddenEventManager, selectedManager: defaultContainer.selectedEventManager, info: info, settings: getSettings(info: info), settingsWindow: defaultContainer.settingsWindow, timer: defaultContainer.timerContainer, listManager: defaultContainer.eventListSettingsManager, filtering: filtering)
    }
    
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
    
    private func customStatusItemContainerDidChange(_ container: StatusItemContainer) {
        // Handle the change and update the array if necessary
        loadCustomStatusItemContainers()
        objectWillChange.send()
    }
    
 
    private func getSettings(info: StatusItemConfiguration) -> StatusItemSettings {
        if info.isCustom &&  info.useDefaultSettings {
            return settingsStore.getSettings(withId: info.identifier!)
        } else {
            return settingsStore.getDefaultSettings()
        }
    }
    
    override func eventsChanged() {
        if defaultContainer.calendarReader.authorization != .notDetermined {
            setUpCustomItemStoreSubscription()
            loadMainStatusItem()
            loadCustomStatusItemContainers()
        }
    }
}


