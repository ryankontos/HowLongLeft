//
//  MainMenuViewModel.swift
//  How Long Left Mac
//
//  Created by Ryan on 25/5/2024.
//

import Foundation
import SwiftUI
import os.log


@MainActor
public class WindowSelectionManager: ObservableObject, SubWindowSelectionManager {
    
    @Published public var menuSelection: String? {
        didSet {
            handleSelectionChange(oldValue: oldValue, newValue: menuSelection)
        }
    }
    
    var locked = false
    
    @Published var scrollPosition: CGPoint = .zero
    
    var latestItems = [String]()
    
    private var itemsProvider: MenuSelectableItemsProvider
    
    public var scrollProxy: ScrollViewProxy?
    
    private var latestHoverDate: Date?
    private var latestKeyDate: Date?
    
    private var selectFromHoverWorkItem: DispatchWorkItem?
    private var setHoverWorkItem: DispatchWorkItem?
    
    private var actualWindowHoverID: String?
    
    let logger: Logger
    
    public weak var submenuManager: FMBEWindowProxy?
    
    @Published public var clickID: String?
    
    var lastSelectWasByKey = false
    var latestScroll: Date?
    
    private var latestMouseMovement: Date?
    
    public var latestMenuHoverId: String?
    
    public init(itemsProvider: MenuSelectableItemsProvider) {
        self.itemsProvider = itemsProvider
       
       
        self.logger = Logger(subsystem: "com.ryankontos.fluid-menu-bar-extra", category: "WindowSelectionManager-\(UUID().uuidString)")
        
        self.latestItems = itemsProvider.getItems()
        
    }
  
    
    public func setScrollLock(_ locked: Bool) {
        
        self.locked = locked
        
        if !locked {
            selectFromHoverWorkItem?.perform()
        } else {
            setMenuItemHovering(id: nil, hovering: false)
        }
    }
    
    /// Called when the state of a user hovering over a subwindow changes.
  
    
    public func setWindowHovering(_ hovering: Bool, id: String?) {
        
       // logger.debug("Set window hovering: \(hovering), id: \(id ?? "nil")")
        
        selectFromHoverWorkItem?.cancel()
        setHoverWorkItem?.cancel()
        
        let item = DispatchWorkItem { [weak self] in
            
            //self?.logger.debug("Running set hover work item, id: \(id ?? "nil")")
            
            guard let self else { return }
            
            if hovering {
                self.actualWindowHoverID = id
            } else {
                self.actualWindowHoverID = nil
            }
            
            
            if hovering {
                menuSelection = id
               // selectID(id)
            } else if menuSelection == id {
                menuSelection = nil
                selectID(latestMenuHoverId)
            }
        }
        
        setHoverWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: item)
    }
    
    /// Called when the state of a user hovering over a menu item changes
    
    public func setMenuItemHovering(id: String?, hovering: Bool) {
        
       
        if id == nil && actualWindowHoverID != nil {
            return
        }
        
        self.latestMenuHoverId = id
        
        selectID(id)
        
    }
    
    private func selectID(_ idToSelect: String?) {
        
        //logger.debug("Select id: \(idToSelect ?? "nil")")
        
   
        selectFromHoverWorkItem?.cancel()
        
        let item = DispatchWorkItem { [weak self] in
            
            
            guard let self else { return }
          
            if self.latestMenuHoverId != idToSelect { return }
            
            latestHoverDate = Date()
          
            if menuSelection != idToSelect {
                menuSelection = idToSelect
            }
        }
        
        let delay: TimeInterval = {
            if let latestScroll = latestScroll, Date().timeIntervalSince(latestScroll) < 1 {
                return 0
            } else {
                
                let prev = menuSelection
                return prev == nil ? 0 : 0
            }
        }()
        selectFromHoverWorkItem = item
        
        
        if !locked || idToSelect == nil {
            
            
           
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
            
        }
    }
    
    public func mouseMoved(point: NSPoint) {
        
        latestMouseMovement = Date()
    }
    
    
    func resetHover() {
        latestKeyDate = nil
        
    }
    
    public func clickItem() {
        clickID = menuSelection
    }
    
    private func handleSelectionChange(oldValue: String?, newValue: String?) {
        
        DispatchQueue.main.async { [self] in
            
          //  //print("Selection changed, old: \(oldValue ?? "nil"), new: \(newValue ?? "nil")")
            
            submenuManager?.window?.closeSubwindow(notify: false)
            
            if let newValue = newValue {
                submenuManager?.window?.openSubWindow(id: newValue)
            }
            
        }
    }
}

public enum OptionsSectionButton: String, CaseIterable {
    case settings, quit
}

@MainActor
public protocol MenuSelectableItemsProvider {
    
    func getItems() -> [String]
    
}

