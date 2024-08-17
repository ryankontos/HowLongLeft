//
//  Panes.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Foundation
import Settings

extension Settings.PaneIdentifier {
    @MainActor static let general = Self("general")
    @MainActor static let calendars = Self("calendars")
    @MainActor static let statusbar = Self("statusbar")
    @MainActor static let hidden = Self("hidden")
}
