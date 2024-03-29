//
//  EventSource.swift
//  How Long Left
//
//  Created by Ryan Kontos on 16/11/21.
//  Copyright © 2021 Ryan Kontos. All rights reserved.
//

import Foundation
import Combine

class EventSource: ObservableObject, EventSourceProtocol {
    
    @Published var eventSections = [TitledEventGroup]()
    
    var isEmpty: Bool = false
    
    var timer: Timer!

    var cardStyle: CountdownCardAppearance?
    
    var allowUpdates = true
    
    init() {
        
        // print("Init event source")
        
        HLLEventSource.shared.addeventsObserver(self)
        update()
        timer = Timer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func update(force: Bool = false) {

        if !allowUpdates {
            return
        }
        
        let pinned = HLLEventSource.shared.getPinnedEventsFromEvents()
        var current = [HLLEvent]()
        var upcoming = [HLLEvent]()
        
        if HLLDefaults.countdownsTab.showInProgress {
            current = HLLEventSource.shared.getCurrentEvents(includeSelected: true)
        }
        
        if HLLDefaults.countdownsTab.showUpcoming {
            upcoming = HLLEventSource.shared.getUpcomingEvents(limit: HLLDefaults.countdownsTab.upcomingCount)
        }
         
        current.removeAll(where: { pinned.contains($0) })
        upcoming.removeAll(where: { pinned.contains($0) })
        
        if HLLDefaults.countdownsTab.onlyEndingToday {
            current.removeAll(where: {  $0.endDate.startOfDay() != Date().startOfDay() })
        }
        
        let currentSection = TitledEventGroup(title: "In Progress", events: current)
        let pinnedSection = TitledEventGroup(title: "Pinned", events: pinned)
        let upcomingSection = TitledEventGroup(title: "Upcoming", events: upcoming)
        
        var newArray = [TitledEventGroup]()
        
        for sectionType in HLLDefaults.countdownsTab.sectionOrder {
            switch sectionType {
            case .pinned:
                if !pinnedSection.isEmpty { newArray.append(pinnedSection) }
            case .inProgress:
                if !currentSection.isEmpty { newArray.append(currentSection) }
            case .upcoming:
                if !upcomingSection.isEmpty { newArray.append(upcomingSection) }
            }
        }
        
        let isEmpty = newArray.compactMap({ $0.events }).isEmpty
            
        if self.isEmpty != isEmpty { self.isEmpty = isEmpty }
        
        
        if self.eventSections.map({$0.id}) != newArray.map({$0.id}) { self.eventSections = newArray }
            
    }
    
}


extension EventSource: EventSourceUpdateObserver {
    
    func eventsUpdated() {
        
        DispatchQueue.main.async {
            self.update()
        }
        
    }
    
}
