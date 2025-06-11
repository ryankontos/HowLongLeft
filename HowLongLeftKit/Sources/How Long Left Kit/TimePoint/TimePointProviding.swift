//
//  TimePointProviding.swift
//  HowLongLeftKit
//
//  Created by Ryan on 10/6/2025.
//

import Foundation
import Combine
import os.log
import SwiftUI

@MainActor
public protocol TimePointProviding: ObservableObject {
    /// All generated time points
    var points: [TimePoint] { get }

    /// The current time point (for Date())
    var currentPoint: TimePoint? { get }

    /// Get the time point at a specific date
    func getPointAt(date: Date) -> TimePoint?

    /// Notifies the provider that underlying events have changed
    func eventsChanged() async
    
    // returns whether the provider has completed its initialisation
    func isReady() -> Bool
}
