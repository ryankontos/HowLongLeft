//
//  TimePoint.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
import Combine

public class TimePoint: Equatable, ObservableObject, Identifiable {
    
    public init(date: Date, inProgressEvents: [Event], upcomingEvents: [Event]) {
        self.date = date
        self.inProgressEvents = inProgressEvents
        self.upcomingEvents = upcomingEvents
    }
    
    public static func == (lhs: TimePoint, rhs: TimePoint) -> Bool {
        return lhs.date == rhs.date && lhs.inProgressEvents == rhs.inProgressEvents && lhs.upcomingEvents == rhs.upcomingEvents
    }
    
    public var id: Date {
        return date
    }
    
    public var date: Date
    @Published public var inProgressEvents: [Event]
    @Published public var upcomingEvents: [Event]
    
}
