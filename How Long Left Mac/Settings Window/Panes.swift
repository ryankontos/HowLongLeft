//
//  Panes.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Foundation
import Settings

@MainActor
extension Settings.PaneIdentifier {
    static let general = Self("general")
    static let calendars = Self("calendars")
    static let statusbar = Self("statusbar")
    static let hidden = Self("hidden")
}
