//
//  MacDefaults.swift
//  How Long Left Mac
//
//  Created by Ryan on 20/6/2024.
//

import Foundation
import Defaults
import HowLongLeftKit

extension Defaults.Keys {
    
    static let mainMenuSortMode = Key<EventListSortMode>("HowLongLeft_Mac_MainMenuSortMode", default: .onNowFirst)

}
