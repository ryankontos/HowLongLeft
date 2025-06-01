//
//  HLLCoreServicesContainer.swift
//  How Long Left
//
//  Created by Ryan on 10/5/2024.
//

import Foundation

@MainActor
open class HLLCoreServicesContainer: ObservableObject {
    
    public let calendarReader: CalendarSource
    public let calendarPrefsManager: CalendarSettingsStore
    public let eventCache: CompositeEventCache
    public let pointStore: TimePointStore
    public let userEventSource: UserEventSource = UserEventSource(container: HLLPersistenceController.shared.persistentContainer)
    
    public let hiddenEventManager: StoredEventManager
    
    public let selectedEventManager: StoredEventManager
    
    public let timerContainer = GlobalTimerContainer()
    
    public init(id: String) {
        
        let domainString = "HowLongLeft_CoreServicesDomain_\(id)"
        
        calendarReader = CalendarSource(requestCalendarAccessImmediately: true)
        
        let appSet: Set<String> = [HLLStandardCalendarContexts.app.rawValue]
        let config = CalendarSettingsStore.Configuration(domain: domainString, defaultContextsForNonMatches: appSet)
        calendarPrefsManager = CalendarSettingsStore(calendarSource: calendarReader, config: config)
        
        hiddenEventManager = StoredEventManager(domain: "\(domainString)_HiddenEvents")
        
        selectedEventManager = StoredEventManager(domain: "\(domainString)_SelectedEvent", limit: 1)
        
        let calCache = CalendarEventCache(calendarReader: calendarReader, calendarProvider: calendarPrefsManager, calendarContexts: [HLLStandardCalendarContexts.app.rawValue], hiddenEventManager: hiddenEventManager, id: "\(domainString)_EventCache")
        
        eventCache = CompositeEventCache(calendarCache: calCache, customSource: userEventSource)
        pointStore = TimePointStore(eventCache: eventCache)
        
        
    }
    
}
