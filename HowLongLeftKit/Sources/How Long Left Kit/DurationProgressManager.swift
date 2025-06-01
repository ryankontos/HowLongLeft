//
//  EventProgressManager.swift
//
//
//  Created by Ryan on 18/6/2024.
//

import Foundation
import Combine

public class DurationProgressManager: ObservableObject {
    @Published public var progress: Double = 0.0
    private var cancellables = Set<AnyCancellable>()
    
    public var percentageString: String {
        // clamp progress to the range [0, 1]
        let clampedProgress = max(0.0, min(1.0, progress))
        // format the percentage string
        return String(format: "%.0f%%", clampedProgress * 100)
    }
    
    private let start: Date
    private let end: Date
    
    public init(event: HLLCalendarEvent) {
        self.start = event.startDate
        self.end = event.endDate
        updateProgress()
        startTimer()
    }
    
    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
        updateProgress()
        startTimer()
    }
    
    private func startTimer() {
        let defaultPublisher = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().map { _ in () }.eraseToAnyPublisher()
        
        defaultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateProgress()
            }
            .store(in: &cancellables)
    }
    
    private func updateProgress() {
        let now = Date()
        guard now >= start else {
            self.progress = 0.0
            return
        }
        guard now <= end else {
            self.progress = 1.0
            return
        }
        
        let totalDuration = end.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)
        self.progress = elapsed / totalDuration
    }
}
