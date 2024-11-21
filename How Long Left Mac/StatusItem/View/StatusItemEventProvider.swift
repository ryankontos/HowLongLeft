//
//  StatusItemEventProvider.swift
//  How Long Left Mac
//
//  Created by Ryan on 16/11/2024.
//

import Foundation
import HowLongLeftKit

class StatusItemEventProvider {
    
    init(pointStore: TimePointStore, selectedManager: StoredEventManager, settings: StatusItemSettings) {
        self.pointStore = pointStore
        self.selectedManager = selectedManager
        self.settings = settings
    }
    
    private var pointStore: TimePointStore
    private var selectedManager: StoredEventManager
    private var settings: StatusItemSettings
        
    @MainActor
    public func getEvent(at date: Date) -> Event? {
        
        guard settings.showCountdowns else { return nil }
        
        guard let point = pointStore.getPointAt(date: date) else { return nil }

        if let selectedEvent = selectedManager.getAllStoredEvents().first,
           let selectedID = selectedEvent.eventID,
           let event = point.allEvents.first(where: { $0.eventID == selectedID }) {
            return event
        }

        let rule = EventFetchRule(rawValue: Int(settings.eventFetchRule))!
        return point.fetchSingleEvent(accordingTo: rule)
    }
    
}
