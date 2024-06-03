//
//  PositionObservingView.swift
//  How Long Left Mac
//
//  Created by Ryan on 31/5/2024.
//

import Foundation
import SwiftUI

struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
    var onChange: (CGPoint) -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: PositionPreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace).origin
                )
            })
            .onPreferenceChange(PositionPreferenceKey.self) { position in
                onChange(position)
            }
    }
}

private extension PositionObservingView {
    struct PositionPreferenceKey: PreferenceKey {
        static var defaultValue: CGPoint { .zero }

        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            value = nextValue()
        }
    }
}
