//
//  StatusItemConfigurationStore.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/6/2024.
//

import Foundation
import HowLongLeftKit
import CoreData

class StatusItemConfigurationStore: ObservableObject {
    
    let context = MacPersistentContainer.shared.container.viewContext
    
    init() {
        createDefaultStatusItemIfNeeded()
    }
    
    func getCustomStatusItems() -> [StatusItemConfiguration] {
        let fetchRequest: NSFetchRequest<StatusItemConfiguration> = StatusItemConfiguration.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier BEGINSWITH %@", "CustomStatusItem_")
        return (try? context.fetch(fetchRequest)) ?? []
    }
        
    func getMainStatusItem() -> StatusItemConfiguration {
        let fetchRequest: NSFetchRequest<StatusItemConfiguration> = StatusItemConfiguration.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", "MainStatusItem")
        return (try? context.fetch(fetchRequest))!.first!
    }
    
    func makeNewCustomStatusItem() -> StatusItemConfiguration {
        
        let item = StatusItemConfiguration(context: context)
        
        let uuidString = UUID().uuidString
        
        item.identifier = "CustomStatusItem_\(uuidString)"
        item.created = Date()
        item.isCustom = true
        return item
        
    }
    
    func saveItem(item: StatusItemConfiguration) {
        context.insert(item)
        try? context.save()
        objectWillChange.send()
    }
    
    func removeCustomStatusItem(item: StatusItemConfiguration) {
        context.delete(item)
        try? context.save()
        objectWillChange.send()
    }
    
    func createDefaultStatusItemIfNeeded() {
        let fetchRequest: NSFetchRequest<StatusItemConfiguration> = StatusItemConfiguration.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", "MainStatusItem")
            
        if let result = try? context.fetch(fetchRequest), result.isEmpty {
            let item = StatusItemConfiguration(context: context)
            item.identifier = "MainStatusItem"
            item.created = Date()
            item.isCustom = false
            item.activated = true
            item.title = "How Long Left"
            saveItem(item: item)
        }
    }
    
}
