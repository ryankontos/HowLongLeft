//
//  File.swift
//  HowLongLeftKit
//
//  Created by Ryan on 30/5/2025.
//

import Foundation

public class EventCountdownTextGenerator: EventInfoStringGenerator {
    
    var showContext: Bool
    var postional: Bool
    var mode: Mode
    
    public init(showContext: Bool, postional: Bool, mode: Mode = .remaining) {
        self.showContext = showContext
        self.postional = postional
        self.mode = mode
    }
    
    public func getString(from event: HLLEvent, at date: Date) -> String {
        let status = event.status(at: date)
        
        switch mode {
        case .remaining:
            switch status {
            case .ended:
                return "Ended"
            case .inProgress:
                let timeString = formatTimeInterval(from: date, to: event.endDate)
                return showContext ? "\(timeString) remaining" : timeString
            case .upcoming:
                let timeString = formatTimeInterval(from: date, to: event.startDate)
                return showContext ? "in \(timeString)" : timeString
            }

        case .elapsed:
            switch status {
            case .upcoming:
                return "Not started"
            case .inProgress:
                let timeString = formatTimeInterval(from: event.startDate, to: date)
                return showContext ? "\(timeString) elapsed" : timeString
            case .ended:
                let timeString = formatTimeInterval(from: event.endDate, to: date)
                return showContext ? "\(timeString) since ended" : timeString
            }
        }
    }
    
    private func formatTimeInterval(from startDate: Date, to endDate: Date) -> String {
        let interval = Int(endDate.timeIntervalSince(startDate))
        let absInterval = abs(interval)

        // Calculate days, hours, minutes, seconds
        let days = absInterval / 86_400
        let hours = (absInterval % 86_400) / 3_600
        let minutes = (absInterval % 3_600) / 60
        let seconds = absInterval % 60

        if postional {
            // If interval is 24 hours or more, show days only
            if days > 1 {
                return "\(days)d"
            }
            // If interval is 1 hour or more (but less than 24h), show hours and minutes only
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            }
            // Under 1 hour: fall back to mm:ss
            if minutes > 0 {
                return String(format: "%02d:%02d", minutes, seconds)
            }
            // Under 1 minute: show just seconds (00:ss)
            return String(format: "00:%02d", seconds)
        } else {
            // Non-positional (“2h 5m 30s” style)
            var components: [String] = []

            if days > 0 {
                components.append("\(days)d")
            }
            if hours > 0 {
                components.append("\(hours)h")
            }
            if minutes > 0 || (hours > 0 && seconds > 0) {
                components.append("\(minutes)m")
            }
            if seconds > 0 && hours == 0 && days == 0 {
                components.append("\(seconds)s")
            }

            // Fallback if all are zero
            if components.isEmpty {
                components.append("0s")
            }

            return components.joined(separator: " ")
        }
    }
    
    public enum Mode {
        case elapsed
        case remaining
    }
}
