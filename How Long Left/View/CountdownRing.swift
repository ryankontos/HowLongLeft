//
//  CountdownRing.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI

struct CountdownRing<Content: View>: View {
    let startDate: Date
    let endDate: Date
    let color: Color
    let lineWidth: CGFloat
    let content: () -> Content

    @Environment(\.colorScheme) private var scheme
    @State private var now: Date = .now
    @State private var animatedProgress: Double = 0.0
    @State private var timer: Timer?

    init(startDate: Date, endDate: Date, color: Color, lineWidth: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.lineWidth = lineWidth
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        (scheme == .dark ? Color.white : Color.black).opacity(0.1),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .interpolatingSpring(stiffness: 60, damping: 17),
                        value: animatedProgress
                    )

                content()
                    .frame(width: size - lineWidth * 2, height: size - lineWidth * 2)
                    .clipped()
            }
            
            .frame(width: geometry.size.width, height: geometry.size.height)
            .padding(lineWidth / 2)
            .drawingGroup()
        }
        .onAppear {
            update()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        
    }

    private var totalDuration: TimeInterval {
        max(endDate.timeIntervalSince(startDate), 1)
    }

    private var remaining: TimeInterval {
        max(endDate.timeIntervalSince(now), 0)
    }

    private var progress: Double {
        let elapsed = now.timeIntervalSince(startDate)
        return min(max(elapsed / totalDuration, 0), 1)
    }

    private func update() {
        now = Date()
        animatedProgress = progress
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                update()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    CountdownRing(
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400),
        color: .blue,
        lineWidth: 10
    ) {
        VStack {
            Text("1d")
                .font(.headline)
            Text("00:00")
                .font(.subheadline)
        }
        .foregroundStyle(.primary)
    }
    .frame(width: 100, height: 100)
    .padding()
}
