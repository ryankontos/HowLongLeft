//
//  MainMenuViewModel.swift
//  How Long Left Mac
//
//  Created by Ryan on 25/5/2024.
//

import Foundation
import HowLongLeftKit
import SwiftUI
import FluidMenuBarExtra

class MainMenuViewModel: ObservableObject, SubWindowSelectionManager {
    
    let mainMenuViewModelQueue = DispatchQueue(label: "HowLongLeftMac.MainMenuViewModelQueue")
    
    @Published var selectedItemID: String?
    
    @Published var scrollPosition: CGPoint = .zero
    
    private let timePointStore: TimePointStore
    
    public var scrollProxy: ScrollViewProxy?
    
    private var latestHoverDate: Date?
    private var latestKeyDate: Date?
    
    private var selectFromHoverWorkItem: DispatchWorkItem?
    private var setHoverWorkItem: DispatchWorkItem?
    
    @Published var clickID: String?
    
    var lastSelectWasByKey = false
    var latestScroll: Date?
    
    var latestActualHoverId: String?
    
    init(timePointStore: TimePointStore) {
        self.timePointStore = timePointStore
    }
    
    func setWindowHovering(_ hovering: Bool, id: String?) {
        
       
        
        selectFromHoverWorkItem?.cancel()
        
        setHoverWorkItem?.cancel()
        
        let item = DispatchWorkItem { [self] in
            
            if hovering {
                
                selectIDFromHover(id)
                
                
            } else {
                if selectedItemID == id {
                    //print("SSII 1")
                    selectedItemID = nil
                    selectIDFromHover(nil)
                }
                
            }
            
        }
        
        self.setHoverWorkItem = item
        
        DispatchQueue.main.async(execute: item)
        
        
    }
    
    
    
    func selectIDFromHover(_ idToSelect: String?) {
        
        
        
        guard idToSelect != selectedItemID else {
            return
            
        }
        
        selectFromHoverWorkItem?.cancel()
        
      
        let item = DispatchWorkItem { [self] in
            latestHoverDate = Date()
            
            
            
            // If the latest key date was in the last 0.5s, ignore and return instead of selecting
            if let latestKeyDate = latestKeyDate, Date().timeIntervalSince(latestKeyDate) < 0.5 {
                return
            }
            
            self.lastSelectWasByKey = false
            if self.selectedItemID != idToSelect {
                self.selectedItemID = idToSelect
               // //print("SSII 2")
            }
           
        }
        
        let delay: TimeInterval = {
            if let latestScroll = latestScroll, Date().timeIntervalSince(latestScroll) < 1 {
                return 1
            } else {
                return idToSelect == nil ? 0.1 : 0
            }
        }()
        
        self.selectFromHoverWorkItem = item
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }
    
    func resetHover() {
        
        latestKeyDate = nil
        if let latestActualHoverId {
            selectedItemID = latestActualHoverId
            //print("SSII 3")
        }
    }
    
    func clickItem() {
        clickID = self.selectedItemID
    }
    
    func selectNextItem() {
        guard let currentID = selectedItemID else {
            selectedItemID = getIdsList().first
            //print("SSII 4")
            return
        }
        
        let ids = getIdsList()
        if let currentIndex = ids.firstIndex(of: currentID), currentIndex + 1 < ids.count {
            selectedItemID = ids[currentIndex + 1]
            //print("SSII 5")
        }
        
        
        self.lastSelectWasByKey = true
        latestKeyDate = Date()
    }
    
    func selectPreviousItem() {
        guard let currentID = selectedItemID else {
            selectedItemID = getIdsList().last
            //print("SSII 6")
            return
        }
        
        let ids = getIdsList()
        if let currentIndex = ids.firstIndex(of: currentID), currentIndex > 0 {
            selectedItemID = ids[currentIndex - 1]
            //print("SSII 7")
        }
        
        self.lastSelectWasByKey = true
        latestKeyDate = Date()
    }
    
    func getIdsList() -> [String] {
        let groups = eventGroups(at: Date())
        return groups.flatMap { $0.events.map { $0.id } } + OptionsSectionButton.allCases.map { $0.rawValue }
    }
    
    func eventGroups(at date: Date) -> [TitledEventGroup] {
        guard let currentPoint = timePointStore.getPointAt(date: date) else { return [] }
        var groups = [
            TitledEventGroup("On Now", currentPoint.inProgressEvents),
        ]
        
        let dates = currentPoint.upcomingGroupedByStartDay
        
        let upcomingGroups = dates.map({  TitledEventGroup("\($0.date.formatted(date: .abbreviated, time: .omitted))", $0.events) })
        
        groups.append(contentsOf: upcomingGroups)
        
        return groups
        
    }
}

public enum OptionsSectionButton: String, CaseIterable {
    case settings, quit
}


