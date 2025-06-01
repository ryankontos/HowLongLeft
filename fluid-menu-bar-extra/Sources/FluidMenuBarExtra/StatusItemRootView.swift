//
//  StatusItemRootView.swift
//  
//
//  Created by Ryan on 26/6/2024.
//

import SwiftUI
import Combine

public struct StatusItemRootView: View {
    var sizePassthrough: PassthroughSubject<CGSize, Never>
    var mainContent: () -> AnyView

    public var body: some View {
        
            mainContent()
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .overlay(
                GeometryReader { geometryProxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self, perform: { size in
                sizePassthrough.send(size)
            })
    }
}



private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}
