//
//  NoCalendarAccessView.swift
//  How Long Left
//
//  Created by Ryan on 11/6/2025.
//

import SwiftUI
import HowLongLeftKit

struct NoCalendarAccessView: View {
    
    @State private var animate = false
    @State var message = NoCalendarAccessMessageProvider().getRandomMessage()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.slash")
                .font(.system(size: 80))
                .foregroundStyle(.red.gradient)
                .scaleEffect(animate ? 1.1 : 1.0)
                .shadow(color: .red.opacity(0.4), radius: 10, x: 0, y: 4)
                .padding(.bottom, 10)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animate)

            Text("No Calendar Access")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animate = true
        }
        .transition(.scale.combined(with: .opacity).animation(.spring(response: 0.6, dampingFraction: 0.7)))
    }
}

#Preview {
    NoCalendarAccessView()
}
