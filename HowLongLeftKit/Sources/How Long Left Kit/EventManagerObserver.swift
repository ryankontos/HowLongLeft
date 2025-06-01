//
//  EventManagerObserver.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import Foundation
@preconcurrency import Combine

@MainActor
open class EventCacheObserver {
    
    public let eventCache: CompositeEventCache
    
    private var eventSubscription: AnyCancellable?
    public static let queue = DispatchQueue(label: "com.howlongleft.EventCacheObserver", attributes: .concurrent)
    
    public init(eventCache: CompositeEventCache) {
        self.eventCache = eventCache
        observeEventChanges()
    }
    
   
    
    open func eventsChanged() async { }
    
    
    private final func observeEventChanges() {
        eventSubscription = eventCache.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                
                Task {
                
                    await self?.eventsChanged()
                }
                
            })
    }
    
    deinit {
        eventSubscription?.cancel()
    }
}

