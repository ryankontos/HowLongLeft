//
//  DefaultContainer.swift
//  How Long Left
//
//  Created by Ryan on 10/5/2024.
//

import Foundation


class DefaultContainer {
    
    init() {
        
        calendarReader = CalendarSource(requestCalendarAccessImmediately: true)
        
        let appSet: Set<String> = [HLLiOSCalendarContexts.app.rawValue]
        let config = EventFilterDefaultsManager.Configuration(domain: "app", defaultContextsForNonMatches: appSet, fetchedContexts: appSet)
        calendarPrefsManager = EventFilterDefaultsManager(calendarSource: calendarReader, config: config)
        
        eventCache = EventCache(calendarReader: calendarReader, calendarProvider: calendarPrefsManager)
        pointStore = TimePointStore(eventCache: eventCache)
        
    }
    
}
