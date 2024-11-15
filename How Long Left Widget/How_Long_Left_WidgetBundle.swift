//
//  How_Long_Left_WidgetBundle.swift
//  How Long Left Widget
//
//  Created by Ryan on 22/9/2024.
//

import WidgetKit
import SwiftUI

@main
struct How_Long_Left_WidgetBundle: WidgetBundle {
    var body: some Widget {
        How_Long_Left_Widget()
    #if os(iOS)
        How_Long_Left_WidgetControl()
        How_Long_Left_WidgetLiveActivity()
    #endif
    }
}
