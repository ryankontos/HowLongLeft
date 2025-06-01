//
//  HLLCalendar.swift
//  HowLongLeftKit
//
//  Created by Ryan on 4/1/2025.
//

import Foundation
import CoreGraphics
import EventKit
import SwiftUI

public class HLLCalendar: Equatable {
    
    public init(ekCalendar: EKCalendar) {
        self.calendarIdentifier = ekCalendar.calendarIdentifier
        self.title = ekCalendar.title
        self.color = Color(ekCalendar.cgColor)
    }
    
    public init(calendarIdentifier: String, title: String, color: Color) {
        self.calendarIdentifier = calendarIdentifier
        self.title = title
        self.color = color
    }
    
    public var calendarIdentifier: String
    public var title: String
    public var color: Color
    
    public static func == (lhs: HLLCalendar, rhs: HLLCalendar) -> Bool {
            return lhs.calendarIdentifier == rhs.calendarIdentifier &&
                   lhs.title == rhs.title &&
                   lhs.color == rhs.color
        }
}
