//
//  File.swift
//  HowLongLeftKit
//
//  Created by Ryan on 10/6/2025.
//

import Foundation
import Combine

@MainActor
public class TimePointProviderWrapper: ObservableObject {
    private var provider: any TimePointProviding

    @Published public private(set) var points: [TimePoint] = []
    public var currentPoint: TimePoint? {
        provider.currentPoint
    }

    public init(provider: any TimePointProviding) {
        self.provider = provider
        self.points = provider.points

   
        (provider.objectWillChange as? ObservableObjectPublisher)?
            .sink { [weak self] _ in
                Task { await self?.sync() }
            }
            .store(in: &cancellables)
        
    }

    public func getPointAt(date: Date) -> TimePoint? {
        provider.getPointAt(date: date)
    }
    
    public func isReady() -> Bool {
        provider.isReady()
    }

    public func eventsChanged() async {
        await provider.eventsChanged()
        await sync()
    }

    private func sync() async {
        // Pull in latest values manually
        await MainActor.run {
            self.points = provider.points
        }
    }

    private var cancellables = Set<AnyCancellable>()
    
    public static func dummy(empty: Bool) -> TimePointProviderWrapper {
        return TimePointProviderWrapper(provider: DummyTimePointStore(empty: empty))
    }
    
}

