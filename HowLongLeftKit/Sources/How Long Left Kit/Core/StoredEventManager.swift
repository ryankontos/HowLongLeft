//
//  StoredEventManager.swift
//  How Long Left Kit
//
//  Created by Ryan on 22/6/2024.
//

import Foundation
import CoreData

@MainActor
public class StoredEventManager: ObservableObject {
    
    @MainActor
    let context = HLLPersistenceController.shared.viewContext
    
    private var domainObject: EventStorageDomain?
    
    private var domain: String = ""
    
    private var limit: Int?
    
    public init(domain: String, limit: Int? = nil) {
        self.domain = domain
        self.limit = limit
        fetchOrCreateDomainObject()
    }
    
    public func removeEventFromStore(eventInfo: StoredEventInfo) {
       
        deleteEventInfo(matching: eventInfo.eventID)
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
    }
    
    public func addEventToStore(event: HLLCalendarEvent, removeIfExists: Bool = false) {
        if removeIfExists {
            if let existingEventInfo = fetchEventInfo(matching: event.eventIdentifier) {
                removeEventFromStore(eventInfo: existingEventInfo)
                return // Return early after removing the existing event
            }
        } else if isEventStored(event: event) {
            // If removeIfExists is false and the event is already stored, return early to avoid duplicates
            return
        }

        if let limit = limit {
            if getAllStoredEvents().count >= limit {
                removeOldestEvent()
            }
        }

        createEventInfo(with: event)

        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    public func getAllStoredEvents() -> [StoredEventInfo] {
        guard let domainObject else { return [] }
        
        let fetchRequest: NSFetchRequest<StoredEventInfo> = StoredEventInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "domain == %@", domainObject)
        
        do {
            let eventInfos = try context.fetch(fetchRequest)
            return eventInfos
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public func isEventStored(event: HLLCalendarEvent) -> Bool {
        return isEventStoredWith(eventID: event.eventIdentifier)
    }
    
    func isEventStoredWith(eventID: String) -> Bool {
        return fetchEventInfo(matching: eventID) != nil
    }
    
    private func fetchOrCreateDomainObject() {
        let fetchRequest: NSFetchRequest<EventStorageDomain> = EventStorageDomain.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "domainID == %@", domain)
        
        do {
            let results = try self.context.fetch(fetchRequest)
            if let existingDomain = results.first {
                self.domainObject = existingDomain
            } else {
                let newDomain = EventStorageDomain(context: self.context)
                newDomain.domainID = domain
                self.domainObject = newDomain
                try self.context.save()
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func purge() {
        guard let items = domainObject?.eventInfos as? [StoredEventInfo] else { return }
        
        for info in items {
            context.delete(info)
        }
        
        try? context.save()
    }
    
    // Create HiddenEventInfo
    private func createEventInfo(with event: HLLCalendarEvent) {
        
        let newHiddenEventInfo = StoredEventInfo(context: context)
        newHiddenEventInfo.eventID = event.eventIdentifier
        newHiddenEventInfo.domain = domainObject
        newHiddenEventInfo.title = event.title
        newHiddenEventInfo.calendarID = event.calendar.calendarIdentifier
        newHiddenEventInfo.startDate = event.startDate
        newHiddenEventInfo.endDate = event.endDate
        newHiddenEventInfo.isAllDay = event.isAllDay
        newHiddenEventInfo.domain = domainObject
        newHiddenEventInfo.storedDate = Date()
        
        domainObject?.addToEventInfos(newHiddenEventInfo)
        
        context.insert(newHiddenEventInfo)
        
        do {
            try context.save()
        } catch {
            //print("Failed to save new HiddenEventInfo: \(error)")
        }
    }
    
    // Fetch HiddenEventInfo matching the eventID
    func fetchEventInfo(matching eventId: String?) -> StoredEventInfo? {
        
        guard let eventId else { return nil }
        
        guard let domainObject else { return nil }
        
        let fetchRequest: NSFetchRequest<StoredEventInfo> = StoredEventInfo.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "domain == %@ AND eventID == %@", domainObject, eventId)
        
        do {
            let eventInfos = try context.fetch(fetchRequest)
            return eventInfos.first
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // Delete HiddenEventInfo
    func deleteEventInfo(matching eventId: String?) {
        guard let hiddenEventInfo = fetchEventInfo(matching: eventId) else { return }
        context.delete(hiddenEventInfo)
        
        do {
            try context.save()
        } catch {
            //print("Failed to delete HiddenEventInfo: \(error)")
        }
    }
    
    // Remove the oldest event based on storedDate
    private func removeOldestEvent() {
        guard let domainObject else { return }
        
        let fetchRequest: NSFetchRequest<StoredEventInfo> = StoredEventInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "domain == %@", domainObject)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "storedDate", ascending: true)]
        fetchRequest.fetchLimit = 1
        
        do {
            let oldestEventInfos = try context.fetch(fetchRequest)
            if let oldestEventInfo = oldestEventInfos.first {
                context.delete(oldestEventInfo)
                try context.save()
            }
        } catch {
            //print("Failed to remove oldest HiddenEventInfo: \(error)")
        }
    }
}
