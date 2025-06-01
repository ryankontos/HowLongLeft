//
//  File.swift
//  HowLongLeftKit
//
//  Created by Ryan on 30/5/2025.
//

import Foundation
import SwiftUI

protocol HLLEventProtocol {
    var title: String { get }
    var startDate: Date { get }
    var endDate: Date { get }
    var calendarName: String { get }
    var color: Color { get }
   

}
