//
//  CircularCountdownView.swift
//  How Long Left Mac
//
//  Created by Ryan on 14/11/2024.
//

import HowLongLeftKit
import SwiftUI

struct CircularCountdownView: View {
    // MARK: - Properties

    @ObservedObject var eventWindow: EventWindow
    var defaultContainer: MacDefaultContainer

    private let lineWidth: CGFloat = 10

    @ObservedObject var pointStore: TimePointStore

    var event: HLLEvent

    // MARK: - Body
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0)) { context in
            let currentTime = context.date
            let progress = calculateProgress(currentTime: currentTime)
            let countdownComplete = progress >= 1.0
            let hasStarted = currentTime >= event.startDate

            VStack {
                Spacer()
                ZStack {
                    if countdownComplete {
                        completionView
                    } else {
                        progressCircle(progress: hasStarted ? progress : 0)
                            .background(timerTextView(currentTime: currentTime, hasStarted: hasStarted))
                            .padding(.top, 25)
                            .frame(maxWidth: 250, maxHeight: 250)
                    }
                }
                .padding(.all, 20)
                Spacer()
            }
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(minWidth: 150, maxWidth: .infinity, minHeight: 150, maxHeight: .infinity)
            .drawingGroup()
        }
    }

    // MARK: - Views

    private var completionView: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(event.color)
                    .transition(.scale)
                    .animation(.easeInOut, value: true)
                    .frame(width: 70, height: 70)
                Image(systemName: "checkmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .transition(.scale)
                    .symbolEffect(.scale, options: .default, isActive: true)
            }

            Text("Event Complete")
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .font(.title2)
        }
    }

    private func progressCircle(progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    event.color.gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
    }

    private func timerTextView(currentTime: Date, hasStarted: Bool) -> some View {
        VStack {
            Text(formattedTime(currentTime: currentTime, hasStarted: hasStarted))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal, 5)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            Text(hasStarted ? "Time Left" : "Starts In")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.all, 15)
    }

    // MARK: - Computed Properties

    private func calculateProgress(currentTime: Date) -> Double {
        guard currentTime >= event.startDate else { return 0 }
        let totalDuration = event.endDate.timeIntervalSince(event.startDate)
        let elapsedTime = currentTime.timeIntervalSince(event.startDate)
        return max(0, min(elapsedTime / totalDuration, 1))
    }

    private func formattedTime(currentTime: Date, hasStarted: Bool) -> String {
        let timeInterval = hasStarted
            ? event.endDate.timeIntervalSince(currentTime)
            : event.startDate.timeIntervalSince(currentTime)

        let hours = Int(timeInterval) / 3_600
        let minutes = (Int(timeInterval) % 3_600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", max(0, hours), max(0, minutes), max(0, seconds))
    }
}
