//
//  StatusItemCountdown.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Foundation
import HowLongLeftKit

@MainActor
class StatusItemCountdown {
    
    public static func countdownString(for event: Event, at now: Date = Date()) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        if now < event.startDate {
            let timeInterval = event.startDate.timeIntervalSince(now)
            let countdown = formatter.string(from: timeInterval) ?? "00:00:00"
            return "\(event.title): in \(countdown)"
        } else if now >= event.startDate && now < event.endDate {
            let timeInterval = event.endDate.timeIntervalSince(now)
            let countdown = formatter.string(from: timeInterval) ?? "00:00:00"
            return "\(event.title): \(countdown)"
        } else {
            return "\(event.title): Ended"
        }
    }

    
}
