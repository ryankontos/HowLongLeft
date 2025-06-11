//
//  NoEventsView.swift
//  How Long Left
//
//  Created by Ryan on 10/6/2025.
//

import SwiftUI
import HowLongLeftKit

struct NoEventsView: View {
    
    @State private var animate = false

    @State var message = NoEventsMessageProvider().getRandomMessage()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hourglass.tophalf.filled")
                .font(.system(size: 80))
                .foregroundStyle(.orange.gradient)
                .scaleEffect(animate ? 1.1 : 1.0)
                .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 4)
                .padding(.bottom, 10)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animate)

            Text("No Events Running")
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
    NoEventsView()
}
