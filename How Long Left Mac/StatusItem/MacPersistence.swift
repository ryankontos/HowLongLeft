//
//  MacPersistence.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/6/2024.
//

import CoreData
import Foundation

class MacPersistentContainer {
    static let shared = MacPersistentContainer()

    let container: NSPersistentCloudKitContainer

    private init() {
        container = NSPersistentCloudKitContainer(name: "MacDataModel")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No descriptions found for persistent store")
        }

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

// Usage:
// let context = PersistentContainer.shared.container.viewContext
