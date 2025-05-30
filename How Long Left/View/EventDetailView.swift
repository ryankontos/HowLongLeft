//
//  EventDetailView.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI
import MapKit
import Combine
import BezelKit
import FluidGradient
import HowLongLeftKit

struct EventDetailView: View {

    @ObservedObject private var event: HLLEvent

    @ObservedObject private var progressManager: DurationProgressManager
    @Environment(\.colorScheme) private var colorScheme

    @State private var mode: CountdownMode = .countdown
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    init(event: HLLEvent) {
        self.event = event
        self._progressManager = ObservedObject(wrappedValue:
            DurationProgressManager(start: event.startDate, end: event.endDate)
        )
    }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 50) {
                        mainCountdownSection(height: geo.size.height * 0.55)
                        aboutCard
                            .padding(.horizontal)
                            .glassCardBackground(cornerRadius: 25)
                            .padding(.horizontal, 12)
                    }
                }
            }
        }
        .tint(event.color)
        .onAppear {
            feedbackGenerator.prepare()
        }
        .onReceive(timer) { now in
            if now > event.endDate && mode == .elapsed {
                withAnimation(.interactiveSpring(response: 0.4,
                                                 dampingFraction: 0.7,
                                                 blendDuration: 0.25)) {
                    mode = .countdown
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {}, label: {
                    Image(systemName: "ellipsis.circle.fill")
                })
                .tint(.primary)
            }
        }
    }

    private func mainCountdownSection(height: CGFloat) -> some View {
        VStack {
            VStack(spacing: 10) {
                Text("IN-PROGRESS")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text(event.title)
                    .font(.system(size: 32, weight: .semibold))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            CountdownRing(
                startDate: event.startDate,
                endDate:   event.endDate,
                color:     event.color,
                lineWidth: 7
            ) {
                Group {
                    VStack(spacing: 6) {
                        countdownText
                            .font(.system(size: 40, weight: .semibold))
                            .multilineTextAlignment(.center)

                        Text(modeLabel)
                            .font(.system(size: 19, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
                .id(mode)
                .transition(
                    .scale(scale: 0.9)
                    .combined(with: .opacity)
                )
                .animation(
                    .interactiveSpring(response: 0.4,
                                       dampingFraction: 0.7,
                                       blendDuration: 0.25),
                    value: mode
                )
               /* .onTapGesture {
                    withAnimation(
                        .interactiveSpring(response: 0.4,
                                           dampingFraction: 0.7,
                                           blendDuration: 0.25)
                    ) {
                        toggleMode()
                    }
                } */
            }
            .shadow(radius: 7)
            .frame(width: 260, height: 260)

            Spacer()

            Text("\(DurationProgressManager(start: event.startDate, end: event.endDate).percentageString) Complete")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .frame(height: height)
        .padding(.top, 10)
    }

    private var countdownText: EventInfoText {
        if mode == .countdown {
            return EventInfoText(
                event,
                stringGenerator: EventCountdownTextGenerator(
                    showContext: false,
                    postional:   true,
                    mode:        .remaining
                )
            )
        } else {
            return EventInfoText(
                event,
                stringGenerator: EventCountdownTextGenerator(
                    showContext: false,
                    postional:   true,
                    mode:        .elapsed
                )
            )
        }
    }

    private var modeLabel: String {
        switch mode {
        case .countdown: return "Remaining"
        case .elapsed:   return "Elapsed"
        }
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            infoRow(icon: "calendar.badge.clock", title: "Starts",
                    value: event.startDate.formatted(date: .abbreviated, time: .shortened))

            Divider().background(Color.white.opacity(0.12))

            infoRow(icon: "flag.checkered", title: "Ends",
                    value: event.endDate.formatted(date: .abbreviated, time: .shortened))

            Divider().background(Color.white.opacity(0.12))

            infoRow(icon: "clock.arrow.circlepath", title: "Duration",
                    value: formatDuration())

           

            if let calendarEvent = event as? HLLCalendarEvent {
                
                Divider().background(Color.white.opacity(0.12))
                
                infoRow(icon: "calendar",
                        title: "Calendar",
                        value: calendarEvent.calendar.title,
                        tint: event.color)
            }
        }
        .padding(22)
    }

    private func infoRow(icon: String,
                         title: String,
                         value: String,
                         tint: Color? = nil,
                         linkAction: (() -> Void)? = nil) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func toggleMode() {
        let now = Date()
        if mode == .countdown && now >= event.startDate {
            feedbackGenerator.impactOccurred()
            mode = .elapsed
        } else if mode == .elapsed {
            feedbackGenerator.impactOccurred()
            mode = .countdown
        }
    }

    private func formatDuration() -> String {
        let interval = event.endDate.timeIntervalSince(event.startDate)
        let hours = Int(interval) / 3600
        let minutes = Int(interval.truncatingRemainder(dividingBy: 3600)) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }

    private enum CountdownMode {
        case countdown
        case elapsed
    }
}

#Preview {
    NavigationStack {
        EventDetailView(
            event: .init(
                title: "Session 1 Recess",
                startDate: Date() - 1000,
                endDate:   Date() + 1000,
                isAllDay:  false,
                color:     .yellow
            )
        )
    }
}
