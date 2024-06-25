//
//  CustomStatusItemStore.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/6/2024.
//

import Foundation
import HowLongLeftKit

class CustomStatusItemStore: ObservableObject {
    
    let context = MacPersistentContainer.shared.container.viewContext
    
    func getCustomCalendarStatusItems() -> [CustomStatusItemInfo] {
        return (try? context.fetch(CustomStatusItemInfo.fetchRequest())) ?? []
    }
    
    func makeNewCustomStatusItem() -> CustomStatusItemInfo {
        
        let item = CustomStatusItemInfo(context: context)
        item.identifier = UUID()
        item.created = Date()
        return item
        
    }
    
    func saveItem(item: CustomStatusItemInfo) {
        context.insert(item)
        try? context.save()
        objectWillChange.send()
    }
    
    func removeCustomStatusItem(item: CustomStatusItemInfo) {
        context.delete(item)
        try? context.save()
        objectWillChange.send()
    }
    
}
