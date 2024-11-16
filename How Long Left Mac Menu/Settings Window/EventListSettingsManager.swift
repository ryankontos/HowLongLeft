//
//  EventListSettingsManager.swift
//  How Long Left Mac
//
//  Created by Ryan on 20/6/2024.
//

import Combine
import Foundation

public class EventListSettingsManager: ObservableObject {
    @Published public var showInProgress = true
    @Published public var showUpcoming = true

    @Published public var upcomingDaysLimit = 10
}
