//
//  HLLTimelineGenerator.swift
//  How Long Left
//
//  Created by Ryan on 27/6/20.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import SwiftUI
import os.log

class HLLTimelineGenerator {
    
    var eventSource: HLLEventSource {
        
        switch self.timelineType {
        case .widget:
            return HLLEventSource.shared
        case .complication:
            if HLLDefaults.complication.mirrorCalendars {
                return HLLEventSource.shared
            }
            return ComplicationEventStore.sharedComplicationStore
        }
        
    }
    
    private let percentDateFetcher = PercentDateFetcher()
    
    var timelineType: TimelineType
    
    static let logger = Logger(subsystem: "TimelineBasedExtensions", category: "Timeline Generation")
    
    init(type: TimelineType) {
        self.timelineType = type
        
        if HLLTimelineGenerator.doneReset {
            return
        }
        
        
        eventSource.updateEvents()
     
        if ProcessInfo.processInfo.arguments.contains("ResetTimelineOnLaunch") {
            HLLDefaults.complication.latestTimeline = nil
        }
        
    }
    
    var timelineConfiguration: HLLTimelineConfiguration?
    var onlyShowEventID: String?
    
    static var doneReset = false

    private let widgetTimelineStorageManager = WidgetHLLTimelineStorageManager()
    
    func reset() {
        
        timelineConfiguration = nil
        onlyShowEventID = nil
    }
    
    func generateHLLTimeline(fast: Bool = false, percentages: Bool = false, forState: TimelineState = .normal) -> HLLTimeline {

        print("Updating \(timelineType) with \(eventSource)")
        
        eventSource.updateEvents(bypassDebouncing: true)
        
            #if !os(macOS)
            
            if timelineType == .complication {
                timelineConfiguration = ComplicatonConfigurationManager().getConfig()
            }
            
            #endif
            
        
        
            var events = Array(eventSource.events.filter({HLLStoredEventManager.shared.isHidden(event: $0) == false})).filter({ $0.completionStatus != .done })
        HLLTimelineGenerator.logger.log("Got \(events.count) events(s) for timeline")
           
            if let config = timelineConfiguration {
                
                if !config.useAllCalendars {
                    events = events.filter({ config.enabledCalendarIDs.contains($0.calendarID ?? "") })
                }
                
            } else {
                
                if let onlyShowEventID = onlyShowEventID {
                    events = events.filter({ onlyShowEventID == $0.id })
                }
                
            }
            
            events.sort(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
            
            var entryDates = Set<Date>()
        
            let midnightTomorrow = Date().startOfDay().addDays(3)
            
            // print("Midnight Tomorrow: \(midnightTomorrow.formattedDate()), \(midnightTomorrow.formattedTime())")
            
            if fast == false {
            
                
            for event in events {
              
                if timelineType == .widget {
                    entryDates.formUnion(percentDateFetcher.fetchPercentDates(for: event, every: 10))
                }
                    
                entryDates.insert(event.startDate)
                entryDates.insert(event.startDate+(5*60))
                entryDates.insert(event.endDate)
                
                if event.completionStatus == .done || HLLStoredEventManager.shared.isHidden(event: event) {
                    
                    if let index = events.firstIndex(of: event) {
                        
                        events.remove(at: index)
                        
                    }
                    
                }
                
            }
                
            }
            
            
            var dictOfAdded = [Date:HLLEvent]()
            
            var midnightedDates = [Date]()
            
            var newDates = [Date]()
            
            entryDates = entryDates.filter({ $0 < midnightTomorrow })
            
            for date in entryDates {
                
                let midnight = date.startOfDay()
                
                if midnightedDates.contains(midnight) == false {
                    midnightedDates.append(midnight)
                    
                    newDates.append(midnight)
                    
                    let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: midnight)!
                    
                    newDates.append(modifiedDate)
                    
                }
                
            }
            
            for date in newDates {
            
                if date.timeIntervalSinceNow < -1 {
                    continue
                }
                
                entryDates.insert(date)
                
            }
            
            
            entryDates.insert(Date().startOfDay())
            entryDates = Set(entryDates.sorted(by: { $0.compare($1) == .orderedAscending }))
            
            var tempEntries = [HLLTimelineEntry]()
            
            for date in entryDates {
                
                
                
                let next = getNextEventsToStart(after: date, from: events)
                
                if let event = getNextEventToStartOrEnd(at: date, from: events) {
                    
                    
                    let entry = HLLTimelineEntry(date: date, event: event, nextEvents: next)
                    tempEntries.append(entry)
                    dictOfAdded[date] = event
                    
                } else {
                    
                    let entry = HLLTimelineEntry(date: date, event: nil, nextEvents: next)
                    tempEntries.append(entry)
                    
                }

                
            }

            
            
           // var empty = events.isEmpty
            
            if tempEntries.isEmpty == true {
                
              //  empty = true
                
                let nextEv = getNextEventsToStart(after: Date(), from: events)
                
                //// print("CompSim6: \(Date().formattedDate()) \(Date().formattedTime()): No event is on, Next: \(nextEv?.title ?? "None")")
                tempEntries.append(HLLTimelineEntry(date: Date(), event: nil, nextEvents: nextEv))
                HLLDefaults.defaults.set("returnItems empty", forKey: "ComplicationDebug")
            }
            

 
            
            tempEntries.sort(by: { $0.date.compare($1.date) == .orderedAscending })
            let timeline = HLLTimeline(state: getTimelineState(), entries: tempEntries, includedEvents: events)
            
     
            // print("Returning timeline with \(timeline.entries.count) entries")
            
           
            
            return timeline
    }
    
    
    
    func getSoonestEndingEvent(at date: Date, from events: [HLLEvent]) -> HLLEvent? {
        
        var currentEvents = [HLLEvent]()
        
        for event in events {
            
            if event.completionStatus(at: date) == .current {
                
                currentEvents.append(event)
                
            }
        }
        
        currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
       
        
        for event in currentEvents {
            // print("On at time: \(event.title)")
        }
        
        
        return currentEvents.first
        
    }
    
  
    
    func getNextEventToStartOrEnd(at date: Date, from events: [HLLEvent]) -> HLLEvent? {
        
        var doSelected = false
        if HLLDefaults.widget.showSelected { doSelected = true }
            
        if doSelected {
            if let selected = eventSource.getPinnedEventsFromEvents().first {
                
                // print("Selected: \(selected)")
                
                if selected.completionStatus(at: date) != .done {
                    // print("Returning Selected: \(selected.title)")
                    return selected
                }
            }
        }
        
        var currentEvents = [HLLEvent]()
        
        for event in events {
            
            if event.completionStatus(at: date) == .done {
                continue
            }
            
            if let timelineConfiguration = timelineConfiguration {
                
                if timelineConfiguration.showUpcoming == false {
                    if event.completionStatus(at: date) == .upcoming {
                        continue
                    }
                }
                
                if timelineConfiguration.showCurrent == false {
                    if event.completionStatus(at: date) == .current {
                        continue
                    }
                }
                
            }
            
            
            currentEvents.append(event)
            
        }
        
        currentEvents.sort(by: { $0.countdownDate(at: date).compare($1.countdownDate(at: date)) == .orderedAscending })
        
        if let timelineConfiguration = timelineConfiguration {
            
            if timelineConfiguration.sortMode == .currentFirst {
                
                currentEvents.sort(by: { $0.completionStatus(at: date) == .current && $1.completionStatus(at: date) == .upcoming })
            }
            
            if timelineConfiguration.sortMode == .upcomingFirst {
                
                currentEvents.sort(by: { $0.completionStatus(at: date) == .upcoming && $1.completionStatus(at: date) == .current })
            }
            
        }
        
        return currentEvents.first
        
    }

    func getNextEventsToStart(after date: Date, from events: [HLLEvent]) -> [HLLEvent] {
        
        return events.filter({$0.completionStatus(at: date) == .upcoming}).sortedEvents(mode: .startDate)
        
    }
    
    func shouldUpdate() -> TimelineValidity {
        
        
        
        let timeline = generateHLLTimeline(forState: .normal).getArchive()
        let newTimeline = timeline
        
        guard let currentTimeline = getStoredTimeline() else {
             print("Needs reloading because no stored timeline.")
            return .needsReloading
        }
        
        if newTimeline.appVersion != currentTimeline.appVersion {
             print("Needs reloading because app versions were different")
            return .needsReloading
        }
        
        if newTimeline.state != currentTimeline.state {
             print("Needs reloading because states were different")
            return .needsReloading
        }
        

    
        let date = newTimeline.creationDate
        
        let newHash = newTimeline.entryHash
        let currentHash = currentTimeline.entryHash
        
         print("Comparing timelines \(newTimeline.creationDate.timeIntervalSinceReferenceDate) and \(currentTimeline.creationDate.timeIntervalSinceReferenceDate)")
        
        print("New has \(newTimeline.entryCount) and current has \(currentTimeline.entryCount)")
        
        if newHash != currentHash {
             print("Timeline dicts did not match, should reload.")
            return .needsReloading
        }
        
         print("Timeline dicts matched, no need to reload.")
        
        return .noUpdateNeeded
        
        
    }
    
    func getStoredTimeline(withID id: String? = nil) -> HLLTimeline.Archive? {
        
        
        switch self.timelineType {
            case .complication:
                return HLLDefaults.complication.latestTimeline
            case .widget:
            return widgetTimelineStorageManager.getTimeline(withID: id)
        }
        
    }
    
    func getTimelineState() -> TimelineState {
        
        return .normal
        
        if HLLDefaults.appData.migratedCoreData == false {
            return .notMigrated
        }
        
        
        #if os(macOS)
        
        if ProStatusManager.shared.isPro == false {
            return .notPurchased
        }
        
        #else
        
      /*  switch timelineType {
        case .widget:
            if !Store.shared.widgetPurchased { return .notPurchased }
        case .complication:
            if !Store.shared.complicationPurchased { return .notPurchased }
        } */
        
        #endif
        
        if CalendarReader.shared.calendarAccess != .Granted {
            
            return .noCalendarAccess
            
        }
        
        return .normal
        
    }
    
    enum TimelineValidity {
        case noUpdateNeeded
        case needsReloading
        case needsExtending
    }
    
}

