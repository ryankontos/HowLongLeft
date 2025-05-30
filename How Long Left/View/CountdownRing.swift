//
//  CountdownRing.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI

struct CountdownRing: View {
    let startDate: Date
    let endDate: Date
    let color: Color
    let lineWidth: CGFloat
    let fontSize: CGFloat
    let fontWeight: Font.Weight

    @Environment(\.colorScheme) private var scheme
    @State private var now: Date = .now
    @State private var animatedProgress: Double = 0.0
    @State private var timer: Timer?

    var body: some View {
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

            Text(remainingString)
                .font(.system(size: fontSize, weight: fontWeight, design: .default))
               
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .monospacedDigit()
                .padding(.horizontal, 40)
                .lineLimit(1)
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
        max(endDate.timeIntervalSince(startDate), 1) // Avoid division by zero
    }

    private var remaining: TimeInterval {
        max(endDate.timeIntervalSince(now), 0)
    }

    private var progress: Double {
        let elapsed = now.timeIntervalSince(startDate)
        return min(max(elapsed / totalDuration, 0), 1)
    }

    private var remainingString: String {
        let totalSeconds = Int(remaining)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if days > 0 {
            var components: [String] = []
            components.append("\(days)d")
            if hours > 0 {
                components.append("\(hours)h")
            }
            return components.joined(separator: " ")
        } else {
            var components: [String] = []
            if hours > 0 {
                components.append(String(format: "%02d", hours))
            }
            if minutes > 0 || hours > 0 {
                components.append(String(format: "%02d", minutes))
            }
            components.append(String(format: "%02d", seconds))
            return components.joined(separator: ":")
        }
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
        lineWidth: 10,
        fontSize: 70,
        fontWeight: .bold
    )
    .frame(width: 300, height: 300)
    .padding()
}
