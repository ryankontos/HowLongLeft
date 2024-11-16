//
//  StatusItemSettingsStore.swift
//  How Long Left Mac
//
//  Created by Ryan on 30/6/2024.
//

import Combine
import CoreData
import Foundation

class StatusItemSettingsStore: ObservableObject {
    let context = MacPersistentContainer.shared.container.viewContext
    private var cache = [String: StatusItemSettings]()
    private var saveSubject = PassthroughSubject<StatusItemSettings, Never>()
    private var cancellables = Set<AnyCancellable>()

    init() {
        saveSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // Adjust interval as needed
            .sink { [weak self] settings in
                self?.performSave(settings: settings)
            }
            .store(in: &cancellables)
    }

    func getSettings() -> [StatusItemSettings] {
        let fetchRequest: NSFetchRequest<StatusItemSettings> = StatusItemSettings.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }

    func getSettings(withId id: String) -> StatusItemSettings {
        let modifiedId = "HowLongLeftMac_StatusItemSettings_\(id)"

        // Check cache first
        if let cachedSettings = cache[modifiedId] {
            return cachedSettings
        }

        let fetchRequest: NSFetchRequest<StatusItemSettings> = StatusItemSettings.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", modifiedId)

        if let settings = try? context.fetch(fetchRequest).first {
            cache[modifiedId] = settings
            return settings
        }
        let newSettings = makeNewSettings(withId: modifiedId)
        cache[modifiedId] = newSettings
        return newSettings
    }

    func getDefaultSettings() -> StatusItemSettings {
        getSettings(withId: "Default")
    }

    func makeNewSettings() -> StatusItemSettings {
        let settings = StatusItemSettings(context: context)
        settings.identifier = UUID().uuidString
        settings.created = Date()
        context.insert(settings)
        try? context.save()
        objectWillChange.send()
        // Cache the new settings
        cache[settings.identifier!] = settings
        return settings
    }

    func makeNewSettings(withId id: String) -> StatusItemSettings {
        let settings = StatusItemSettings(context: context)
        settings.identifier = id
        settings.created = Date()
        settings.showTitles = false
        context.insert(settings)
        try? context.save()
        objectWillChange.send()
        // Cache the new settings
        cache[id] = settings
        return settings
    }

    func saveSettings(settings: StatusItemSettings) {
        saveSubject.send(settings)
    }

    private func performSave(settings: StatusItemSettings) {
        DispatchQueue.main.async { [self] in
            if context.insertedObjects.contains(settings) {
                try? context.save()
            } else {
                context.insert(settings)
                try? context.save()
            }
        }
        // Update the cache
        cache[settings.identifier!] = settings
        objectWillChange.send()
    }

    func removeSettings(settings: StatusItemSettings) {
        context.delete(settings)
        try? context.save()
        // Remove from the cache
        cache.removeValue(forKey: settings.identifier!)
        objectWillChange.send()
    }
}
