//
//  File.swift
//  
//
//  Created by Ryan on 6/5/2024.
//

import Foundation
import EventKit

extension EKEvent: @retroactive Identifiable {
    
    public var id: String {
        return "\(eventIdentifier!)\(startDate!)\(endDate!)\(title!)\(self.calendar.calendarIdentifier)"
    }
    
    public var modifiedOrCreatedDate: Date {
        return self.lastModifiedDate ?? self.creationDate ?? self.startDate
    }
    
}
