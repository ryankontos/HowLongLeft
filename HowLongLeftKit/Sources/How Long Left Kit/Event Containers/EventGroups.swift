//
//  MainMenuEventGroups.swift
//  How Long Left Mac
//
//  Created by Ryan on 9/11/2024.
//

import Foundation

public struct EventGroups {
    
    public init(headerGroups: [TitledEventGroup], upcomingGroups: [TitledEventGroup]) {
        self.headerGroups = headerGroups
        self.upcomingGroups = upcomingGroups
    }

    public var isEmpty: Bool {
        return headerGroups.isEmpty && upcomingGroups.isEmpty
        
    }
    
    public var headerGroups = [TitledEventGroup]()
    public var upcomingGroups = [TitledEventGroup]()
    
}
