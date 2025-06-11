//
//  CompositeEventCache.swift
//  HowLongLeftKit
//
//  Created by Ryan on 21/5/2025.
//

import Foundation
import CoreData
import Combine

@MainActor
public class CompositeEventCache: ObservableObject {
    public let calendarCache: CalendarEventCache?
    private let customSource: UserEventSource?
    @Published public private(set) var allEvents: [HLLEvent] = []
    private var cancellables: Set<AnyCancellable> = []

   
    
    public var cacheSummaryHash: String {
        let calHash = calendarCache?.cacheSummaryHash
        let customHash = customSource?.eventSummaryHash ?? ""
        return "\(calHash ?? ""),\(customHash)".hashValue.description
        
    }
    
    @Published public var showCalendarEvents: Bool = true {
        didSet {
            if showCalendarEvents != oldValue {
                rebuild()
            }
        }
        
    }
    @Published public var showCustomEvents: Bool = true {
        didSet {
            if showCustomEvents != oldValue {
                rebuild()
            }
        }
        
    }
    
    public init(calendarCache: CalendarEventCache? = nil,
                customSource: UserEventSource? = nil,
                includeCalendarEvents: Bool = true) {
        self.calendarCache = calendarCache
        self.customSource = customSource
        self.showCalendarEvents = includeCalendarEvents

        // subscribe to changes
        
        if let customSource, let calendarCache {
            
            
            calendarCache.objectWillChange
                .merge(with: customSource.objectWillChange)
                .sink { [weak self] in self?.rebuild() }
                .store(in: &cancellables)
            
        }

        rebuild()
    }
    
    var id: String {
        return calendarCache?.id ?? ""
    }
    
    func getEvents() async -> [HLLEvent] {
        return allEvents
    }
    
    public func isReady() -> Bool {
        return calendarCache?.hasFetched ?? false
    }

    private func rebuild() {
        Task {
            let cal = showCalendarEvents ? await calendarCache?.getEvents() : []
            let cust = showCustomEvents ? customSource?.customEvents : []
            let unified: [HLLEvent] = ((cal ?? []) as [HLLEvent]) + ((cust ?? []) as [HLLEvent])
            self.allEvents = unified.sorted { $0.startDate < $1.startDate }
            self.objectWillChange.send()
        }
    }
}
