//
//  BackgroundGradient.swift
//  How Long Left
//
//  Created by Ryan on 5/6/2025.
//

import SwiftUI

struct PremiumBackground: View {
    var body: some View {
        ZStack {
            // Layer 1: Soft radial base
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.2),
                    Color(red: 0.12, green: 0.15, blue: 0.35)
                ]),
                center: .center,
                startRadius: 20,
                endRadius: 500
            )
            .ignoresSafeArea()

            // Layer 2: Angular highlight
            AngularGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.4),
                    Color(red: 0.2, green: 0.3, blue: 0.6),
                    Color(red: 0.1, green: 0.1, blue: 0.4)
                ]),
                center: .center
            )
            .blendMode(.overlay)
            .opacity(0.6)

            // Optional: Overlay blur or glass effect
            Color.black.opacity(0.2)
                .blur(radius: 60)
        }
    }
}

#Preview {
    PremiumBackground()
}
