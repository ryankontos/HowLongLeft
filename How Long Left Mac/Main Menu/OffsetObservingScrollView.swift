//
//  OffsetObservingScrollView.swift
//  How Long Left Mac
//
//  Created by Ryan on 31/5/2024.
//

import Foundation
import SwiftUI

struct OffsetObservingScrollView<Content: View>: View {
    var axes: Axis.Set = [.vertical]
    var showsIndicators = true
    var onOffsetChange: (CGPoint) -> Void
    @ViewBuilder var content: () -> Content

    private let coordinateSpaceName = UUID()

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                onChange: { newOffset in
                    onOffsetChange(CGPoint(x: -newOffset.x, y: -newOffset.y))
                },
                content: content
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}
