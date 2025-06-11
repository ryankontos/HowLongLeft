//
//  GlassCardModifier.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//  Simplified 11/6/2025 – minimal look with subtle border.
//

import SwiftUI

private struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var material: Material = .ultraThinMaterial

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(material)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    /// Adds a minimal glass effect with corner radius and a subtle border.
    func glassCardBackground(cornerRadius: CGFloat = 22, material: Material = .ultraThinMaterial) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, material: material))
    }
}
