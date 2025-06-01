//
//  EventListSettingsManager.swift
//  How Long Left
//
//  Created by Ryan on 20/6/2024.
//

import Foundation
import Defaults
import Combine

public class EventListSettingsManager: ObservableObject {

    private let domain: String
    
    public init(domain: String) {
        self.domain = domain
    }
    
    private func makeKey<T>(_ name: String, default value: T) -> Defaults.Key<T> {
        return Defaults.Key<T>("HowLongLeft_EventList_\(domain)_\(name)", default: value)
    }
    
    private var showInProgressKey: Defaults.Key<Bool> {
        makeKey("showInProgress", default: true)
    }
    
    private var showInProgressWhenEmptyKey: Defaults.Key<Bool> {
        makeKey("showInProgressWhenEmpty", default: true)
    }
    
    
    private var showUpcomingKey: Defaults.Key<Bool> {
        makeKey("showUpcoming", default: true)
    }
    
    private var showEmptyUpcomingDaysKey: Defaults.Key<Bool> {
        makeKey("showEmptyUpcomingDays", default: true)
    }
    
    private var sortKey: Defaults.Key<EventListSortMode> {
        makeKey("sortMode", default: .onNowFirst)
    }
    
    private var upcomingDaysLimitKey: Defaults.Key<Int> {
        makeKey("upcomingLimit", default: 14)
    }
    
    private func get<T>(_ key: Defaults.Key<T>) -> T {
        return Defaults[key]
    }
    
    private func set<T>(_ key: Defaults.Key<T>, value: T) {
        Defaults[key] = value
        objectWillChange.send()
    }
    
    public var showInProgress: Bool {
        get { get(showInProgressKey) }
        set { set(showInProgressKey, value: newValue) }
    }
    
    public var showInProgressWhenEmpty: Bool {
        get { get(showInProgressWhenEmptyKey) }
        set { set(showInProgressWhenEmptyKey, value: newValue) }
    }
    
    public var showUpcoming: Bool {
        get { get(showUpcomingKey) }
        set { set(showUpcomingKey, value: newValue) }
    }
    
    public var upcomingDaysLimit: Int {
        get { get(upcomingDaysLimitKey) }
        set { set(upcomingDaysLimitKey, value: newValue) }
    }
    
    public var showEmptyUpcomingDays: Bool {
        get { get(showEmptyUpcomingDaysKey) }
        set { set(showEmptyUpcomingDaysKey, value: newValue) }
    }
    
    public var sortMode: EventListSortMode {
        get { get(sortKey) }
        set { set(sortKey, value: newValue) }
    }
    
    public var showAllMultiDayEventDays: Bool {
        return true
    }
}



public enum EventListSortMode: Int, Defaults.Serializable {
    
    case onNowFirst
    case upcomingFirst
    case chronological
    
    
}


// Define a protocol for fetching settings
public protocol EventListSettingsFetcher {
    var showInProgress: Bool { get }
    var showInProgressWhenEmpty: Bool { get }
    var showUpcoming: Bool { get }
    var upcomingDaysLimit: Int { get }
    var showEmptyUpcomingDays: Bool { get }
    var sortMode: EventListSortMode { get }
    var showAllMultiDayEventDays: Bool { get }
    
}

// Extend EventListSettingsManager to conform to the protocol
extension EventListSettingsManager: EventListSettingsFetcher {
    // No additional implementation needed since the properties already exist
}
