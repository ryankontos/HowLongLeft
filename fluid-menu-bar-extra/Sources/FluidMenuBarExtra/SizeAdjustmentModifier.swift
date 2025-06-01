//
//  SizeAdjustmentModifier.swift
//  FluidMenuBarExtra
//
//  Created by Ryan on 12/11/2024.
//

import Foundation
import SwiftUI

struct SizeAdjustmentModifier: ViewModifier {
    let mode: ResizeMode

    func body(content: Content) -> some View {
        if mode == .windowDriven {
            content.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            content
        }
    }
}
