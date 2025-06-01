//
//  File.swift
//  HowLongLeftKit
//
//  Created by Ryan on 16/11/2024.
//

import Foundation

extension Date {
    
    public static var previousSecondWithMillisecondZero: Date {
        let currentDate = Date()
        let calendar = Calendar.current

        guard let previousSecondDate = calendar.date(byAdding: .second, value: -1, to: currentDate) else {
            fatalError("Failed to create the date with millisecond set to zero.")
        }

        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                 from: previousSecondDate)
        components.nanosecond = 0

        return calendar.date(from: components) ?? {
            fatalError("Failed to create the date with millisecond set to zero.")
        }()
    }
    
}
