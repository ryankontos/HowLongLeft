//
//  EventFetchResult.swift
//  HowLongLeftKit
//
//  Created by Ryan on 4/1/2025.
//

import Foundation
import CryptoKit

public struct EventFetchResult {
    var events: [HLLCalendarEvent]
    var calendars: [HLLCalendar]
    var predicateStart: Date?
    var predicateEnd: Date?

    func getHash() -> String {
            var dataToHash = ""

        
            for event in events {
                 let id = String(event.id)
                    dataToHash += id
            
            }

            // Collect calendar identifiers
            for calendar in calendars {
                dataToHash += calendar.calendarIdentifier
            }

            // Add predicateStart and predicateEnd if they exist
            if let start = predicateStart {
                dataToHash += String(start.timeIntervalSince1970)
            }
            
            if let end = predicateEnd {
                dataToHash += String(end.timeIntervalSince1970)
            }

            // Ensure there is data to hash
            guard !dataToHash.isEmpty else { return "" }
            
            // Create a SHA-256 hash of the combined string
            let hashData = SHA256.hash(data: Data(dataToHash.utf8))

            // Convert the hash to a string
            return hashData.map { String(format: "%02x", $0) }.joined()
        }
    
    
}
