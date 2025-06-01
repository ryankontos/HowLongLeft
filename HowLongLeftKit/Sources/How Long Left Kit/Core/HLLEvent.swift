//
//  HLLEvent.swift
//  HowLongLeftKit
//
//  Created by Ryan on 21/5/2025.
//

import Foundation
import Combine
import SwiftUI

open class HLLEvent: ObservableObject, Equatable, Hashable, Identifiable {
    
    public static func == (lhs: HLLEvent, rhs: HLLEvent) -> Bool {
        lhs.infoHash == rhs.infoHash
    }

    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(eventIdentifier)
    }
    
    public var id: String {
        return infoHash
    }
    
    @Published open var locationName: String?
    @Published open var title: String
    @Published open var startDate: Date
    @Published open var endDate: Date
    @Published open var isAllDay: Bool
    @Published open var eventIdentifier: String
    
    // public get only
    @Published public private(set) var color: Color
    
    public init(title: String, startDate: Date, endDate: Date, isAllDay: Bool, eventIdentifier: String = UUID().uuidString, color: Color) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.color = color
        self.eventIdentifier = eventIdentifier
    }
    
    open func status(at date: Date = Date()) -> Status {
        if date < startDate {
            return .upcoming
        } else if date < endDate {
            return .inProgress
        } else {
            return .ended
        }
    }
    
    open func completion(at date: Date = Date()) -> Double {
        guard startDate <= date, endDate > date else {
            return startDate > date ? 0.0 : 1.0
        }
        let total = endDate.timeIntervalSince(startDate)
        let elapsed = date.timeIntervalSince(startDate)
        return max(0.0, min(1.0, elapsed / total))
    }
    
    public static func makeExampleEvent(title: String, start: Date = .now, end: Date, color: Color) -> HLLEvent {
        
        return HLLEvent(title: title, startDate: start, endDate: end, isAllDay: false, eventIdentifier: UUID().uuidString, color: color)
        
       
    }

    public static var example: HLLEvent {
        
        return HLLEvent.makeExampleEvent(title: "Example Event", end: Date().addingTimeInterval(3500), color: .blue)
        
    }
    
    open func countdownDate(at date: Date = Date()) -> Date {
        return status(at: date) == .upcoming ? startDate : endDate
    }
    
    var infoHash: String {
        return "\(title)-\(startDate.timeIntervalSince1970)-\(endDate.timeIntervalSince1970)-\(eventIdentifier)"
    }
    
    public enum Status {
        case ended, inProgress, upcoming
    }
}

public extension Array where Element == HLLEvent {
    
    // Function to sort by start date
    func sortedByStartDate() -> [HLLEvent] {
        return self.sorted { $0.startDate < $1.startDate }
    }
    
    // Function to sort by end date
    func sortedByEndDate() -> [HLLEvent] {
        return self.sorted { $0.endDate < $1.endDate }
    }
    
    func onlyCalendarEvents() -> [HLLCalendarEvent] {
        return self.compactMap { $0 as? HLLCalendarEvent }
    }
    
    func infoHash() -> String {
        let hashes = self.map { $0.infoHash }
        return hashes.joined(separator: "-").data(using: .utf8)?.base64EncodedString() ?? ""
    }
}
