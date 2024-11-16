//
//  MacSettingsTab.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/6/2024.
//

import Foundation

enum MacSettingsTab: String, Hashable, CaseIterable, Identifiable {
    case general
    case calendars
    case menuBar
    case customMenuBarItems
    case hidden

    var id: String { self.rawValue }
}
