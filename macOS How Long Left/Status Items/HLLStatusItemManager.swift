//
//  HLLStatusItemManager.swift
//  How Long Left (macOS)
//
//  Created by Ryan on 29/6/20.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation


class HLLStatusItemManager {
    
    static var shared: HLLStatusItemManager!
    
    var timerHandler: HLLStatusItemUpdateHandler!
    
    var mainStatusItem: HLLStatusItem?
    var eventStatusItems = [HLLStatusItem]()
    
    var allStatusItems: [HLLStatusItem] {
        
        get {
            
            var returnArray = eventStatusItems
            if let item = mainStatusItem {
                returnArray.insert(item, at: 0)
            }
           
            return returnArray
            
        }
        
    }
    
    var eventStatusItemEvents = [HLLEvent]()
  
   
    init() {
        
       
        self.timerHandler = HLLStatusItemUpdateHandler(delegate: self)
        
        DispatchQueue.main.async {
        
            HLLStoredEventManager.shared.observers.append(self)
        //self.createStatusItems()
            
        }
        
        HLLEventSource.shared.addeventsObserver(self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.createStatusItems()
        }
        
        
    }
    
    func addEventStatusItem(with event: HLLEvent) {
        
     //   // print("ESI: Add with event")
        
        if let item = HLLDefaults.defaults.object(forKey: "EventStatusItems") as? [String:[String:String]] {
            
         //   // print("ESI: 1 \(event.persistentIdentifier)")
            
            var newItem = item
            newItem[event.persistentIdentifier] = ["":""]
            HLLDefaults.defaults.set(newItem, forKey: "EventStatusItems")
            
        } else {
            
          //  // print("ESI: 2 \(event.persistentIdentifier)")
            
            var newItem = [String:[String:String]]()
            newItem[event.persistentIdentifier] = ["":""]
            HLLDefaults.defaults.set(newItem, forKey: "EventStatusItems")
            
        }
        
        createStatusItems()
        
    }
    
    func removeEventStatusItem(with event: HLLEvent) {
        
        if self.allStatusItems.isEmpty {
            return
        }
        
        if let item = HLLDefaults.defaults.object(forKey: "EventStatusItems") as? [String:[String:String]] {
            
            var newItem = item
            newItem[event.persistentIdentifier] = nil
            HLLDefaults.defaults.set(newItem, forKey: "EventStatusItems")
            
        }
        
       eventStatusItems.removeAll(where: { statusItem in
       
            
            if statusItem.configuration.eventRetriver.retrieveEvent()?.persistentIdentifier == event.persistentIdentifier {
                statusItem.remove()
                return true
            }
                
            
            
            return false
            
            
        })
        
        updateEvents()
        createStatusItems()
        
    }
    
    func createStatusItems() {
        
       // // print("ESI: Creating")
        
        if mainStatusItem == nil {
            mainStatusItem = HLLStatusItem(configuration: .defaultConfiguration())
        }
        
        
        
        var tempEventStatusItems = [HLLStatusItem]()
        
        if let dict = HLLDefaults.defaults.object(forKey: "EventStatusItems") as? [String:[String:String]] {
            
            var alreadyAdded = [String]()
            
            var ids = [String]()
            for key in dict.keys { ids.append(key) }
            
          //  // print("ESI Create: Dict \(dict)")
            
            for event in HLLEventSource.shared.events {
                
                if ids.contains(event.persistentIdentifier), !alreadyAdded.contains(event.persistentIdentifier) {
                    
                    alreadyAdded.append(event.persistentIdentifier)
                    tempEventStatusItems.append(HLLStatusItem(configuration: .eventConfiguration(event)))
                //    // print("ESI: Appending \(event.persistentIdentifier)")
                    
                }
                
            }
            
            
        }
        
        for item in eventStatusItems {
            item.remove()
        }
        
        eventStatusItems.removeAll()
        eventStatusItems = tempEventStatusItems
        updateEvents()
        
        
    }

    func updateEvents() {
        
        var eventArray = [HLLEvent]()
               
               for statusItem in eventStatusItems {
                   
                   if let event = statusItem.configuration?.eventRetriver.retrieveEvent() {
                       eventArray.append(event)
                   }
                                   
               }
        
     //   self.mainStatusItem.statusItem?.isVisible = eventStatusItems.isEmpty
               
               self.eventStatusItemEvents = eventArray
        
        
        
    }
    
    func updateAll() {
        
        self.timerHandler.activeUpdate()
        
    }
    
}

extension HLLStatusItemManager: EventSourceUpdateObserver {
    
    func eventsUpdated() {
        DispatchQueue.main.async {
            self.createStatusItems()
            self.timerHandler.activeUpdate()
        }
       
      
    }
       
    
}


extension HLLStatusItemManager: EventHidingObserver {
    
    func eventWasHidden(event: HLLEvent) {
        removeEventStatusItem(with: event)
        
    }
    
}
