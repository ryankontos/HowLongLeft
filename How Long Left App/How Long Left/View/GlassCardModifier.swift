//
//  GlassCardModifier.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//  Updated 30/4/2025 – optimised without colour banding.
//

import SwiftUI

private struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var cornerRadius: CGFloat = 22

    func body(content: Content) -> some View {
        let strokeGradient = LinearGradient(
            gradient: Gradient(colors: [
                (scheme == .dark ? Color.white : .black).opacity(0.15),
                (scheme == .dark ? Color.white : .black).opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        let fillGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(scheme == .dark ? 0.10 : 0.20),
                .clear
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(fillGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(strokeGradient, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // clip once
            .shadow(
                color: .black.opacity(scheme == .dark ? 0.35 : 0.08),
                radius: scheme == .dark ? 6 : 4,
                x: 0, y: scheme == .dark ? 4 : 2
            )
    }
}

extension View {
    func glassCardBackground(cornerRadius: CGFloat = 22) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}
