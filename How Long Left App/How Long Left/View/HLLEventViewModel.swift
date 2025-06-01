//
//  HLLEventViewModel.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import Foundation
import SwiftUI
import HowLongLeftKit

class HLLEventViewModel: Identifiable {
    
    var title: String
    var startDate: Date
    var endDate: Date
    var calendarName: String
    var color: Color
    
    var locationName: String? = "Home"
    
    var notes: String? = "This is a big day!"
    
    var progress = 0.5
    
    var durationString: String {
        let duration = endDate.timeIntervalSince(startDate)
        return String(format: "%.1f", duration)
    }
    
    var id: String
    
    init(title: String, start: Date, end: Date, calendar: String, color: Color) {
        self.title = title
        self.startDate = start
        self.endDate = end
        self.calendarName = calendar
        self.color = color
        self.id = UUID().uuidString
    }
    
    init(event: HLLCalendarEvent) {
        self.title = event.title
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.calendarName = event.calendar.title
        self.color = event.color
        self.id = event.id
    }
    
}
