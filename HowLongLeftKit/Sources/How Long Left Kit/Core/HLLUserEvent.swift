//
//  HLLUserEvent.swift
//  HowLongLeftKit
//
//  Created by Ryan on 21/5/2025.
//

import Foundation
import SwiftUI

public class HLLUserEvent: HLLEvent {

    public override init(title: String, startDate: Date, endDate: Date, isAllDay: Bool, eventIdentifier: String = UUID().uuidString, color: Color) {
        super.init(title: title, startDate: startDate, endDate: endDate, isAllDay: isAllDay, color: color)
    }
    
}
