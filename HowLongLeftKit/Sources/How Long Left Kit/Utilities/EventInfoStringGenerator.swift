//
//  File.swift
//  
//
//  Created by Ryan on 18/6/2024.
//

import Foundation

public protocol EventInfoStringGenerator {
    func getString(from event: HLLEvent, at date: Date) -> String
}
