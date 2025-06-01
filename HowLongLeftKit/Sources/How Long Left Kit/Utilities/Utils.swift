//
//  Utils.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import Foundation

internal func updateIfNeeded<T: Equatable>(_ variable: inout T, compareTo: T, flag: inout Bool) {
    if variable != compareTo {
        variable = compareTo
        flag = true
    }
}
