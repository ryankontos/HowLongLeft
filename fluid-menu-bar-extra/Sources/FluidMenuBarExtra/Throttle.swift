//
//  File 2.swift
//  HowLongLeftKit
//
//  Created by Ryan on 8/11/2024.
//

import Foundation
import Combine

extension Publishers {
    // Throttle operator that suppresses frequent updates within the specified interval
    static func throttle<T: Equatable>(_ publisher: Published<T>.Publisher, interval: TimeInterval) -> AnyPublisher<T, Never> {
        return publisher
            .removeDuplicates()
            .debounce(for: .seconds(interval), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
