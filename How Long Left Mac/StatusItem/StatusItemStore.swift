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
    
    var mainManager: StatusItemManager!
    unowned var defaultContainer: MacDefaultContainer

    @Published var customStatusItemContainers = Set<CustomStatusItemContainer>()
    private var cancellables: Set<AnyCancellable> = []
    
    private var customItemStoreSubscription: AnyCancellable?
    
    let customStatusItemStore = CustomStatusItemStore()
    
    let mainConfigInfo = MenuConfigurationInfo()
    
    init(container: MacDefaultContainer) {
        self.defaultContainer = container
        super.init(eventCache: container.eventCache)
        
    }
    
    func createNewCustomStatusItem() -> CustomStatusItemContainer {
        let newInfo = customStatusItemStore.makeNewCustomStatusItem()
        let container = initalizeCustomStatusItemContainer(from: newInfo)
        customStatusItemContainers.insert(container)
        updateSubscriptions()
        return container
    }
    
    func loadCustomStatusItemContainers() {
        print("Loading containers, there are currently \(self.customStatusItemContainers.count)")
        var newContainers = Set<CustomStatusItemContainer>()
        let existing = customStatusItemContainers
        let newInfos = customStatusItemStore.getCustomCalendarStatusItems()
        
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
            existingItem.statusItem?.destoryMenuItem()
        }
        
        print("Finished loading containers, there are now \(newContainers.count)")
        self.customStatusItemContainers = newContainers
        updateSubscriptions()
    }
    
    private func initalizeCustomStatusItemContainer(from info: CustomStatusItemInfo) -> CustomStatusItemContainer {
        return CustomStatusItemContainer(source: defaultContainer.calendarReader, hiddenEventManager: defaultContainer.hiddenEventManager, info: info, settings: defaultContainer.settingsWindow, timer: defaultContainer.timerContainer, listManager: defaultContainer.eventListSettingsManager)
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
        
        self.customItemStoreSubscription = customStatusItemStore.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.loadCustomStatusItemContainers()
                    self?.objectWillChange.send()
                }
            }
           
        
    }
    
    private func customStatusItemContainerDidChange(_ container: CustomStatusItemContainer) {
        // Handle the change and update the array if necessary
        loadCustomStatusItemContainers()
        objectWillChange.send()
    }
    
    func createMainMenu() {
        let model = MainMenuViewModel(timePointStore: self.defaultContainer.pointStore, listSettings: self.defaultContainer.eventListSettingsManager)
        
        let mainExtra = FluidMenuBarExtraWindowManager(title: "How Long Left", windowContent: {
            AnyView(MainMenuContentView(selectionManager: WindowSelectionManager(itemsProvider: model), model: model)
                .environmentObject(self.defaultContainer.hiddenEventManager)
                .environmentObject(self.defaultContainer.eventListSettingsManager)
                .environmentObject(self.defaultContainer.settingsWindow)
                .environmentObject(self.defaultContainer.pointStore)
                .environmentObject(self.defaultContainer.calendarReader)
                .environmentObject(self.defaultContainer.timerContainer)
                .environmentObject(self.mainConfigInfo)
            )
        }, statusItemContent: {
            AnyView(
                
                StatusItemContentView()
                    .environmentObject(self.defaultContainer.pointStore)
                    .environmentObject(self.mainConfigInfo)
            
            
            )
        })
        
       
      
        let statusItemPointStore = TimePointStore(eventCache: self.defaultContainer.statusItemEventFilter)
        
        self.mainManager = StatusItemManager(menubarExtra: mainExtra, timePointStore: statusItemPointStore, statusItemPointStore: statusItemPointStore, customTitle: nil)
    }
    
    override func eventsChanged() {
        if mainManager == nil && defaultContainer.calendarReader.authorization != .notDetermined {
            createMainMenu()
            setUpCustomItemStoreSubscription()
            loadCustomStatusItemContainers()
        }
    }
}


