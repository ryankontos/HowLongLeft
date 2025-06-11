//
//  ProminentCountdownCard.swift
//  How Long Left
//
//  Created by Ryan on 5/6/2025.
//

import SwiftUI
import HowLongLeftKit

struct ProminentCountdownCard: View {
    @ObservedObject var event: HLLEvent

    var body: some View {
        
        let _ = Self._printChanges()
        
        VStack(spacing: 25) {
            CountdownRing(
                startDate: event.startDate,
                endDate: event.endDate,
                color: event.color,
                lineWidth: 8,
                content: {
                    EventInfoText(
                        event,
                        stringGenerator: EventCountdownTextGenerator(
                            showContext: false,
                            postional: true,
                            mode: .remaining)
                    )
                    .font(.system(size: 20, weight: .bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 6)
                }
            )
            .frame(width: 120, height: 120)
            
            VStack(spacing: 10) {
                Text(event.title)
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)

                if let location = dummyLocation {
                    Text(location)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.blue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                timeLabel
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }

        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .glassCardBackground()
        .onAppear {
            print("ProminentCountdownCard appeared for event: \(event.title)")
        }
    }

    private var dummyLocation: String? {
        // In real implementation, this might be event.location or event.structuredLocation?.title
        return "Apple Park, Cupertino"
    }

    private var timeLabel: some View {
        let df = DateFormatter()
        df.locale = .autoupdatingCurrent
        if Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate),
           Calendar.current.isDateInToday(event.startDate) {
            df.dateFormat = "h:mm a"
        } else {
            df.dateFormat = "d MMM, h:mm a"
        }
        return Text("\(df.string(from: event.startDate)) – \(df.string(from: event.endDate))")
    }
}

#Preview {
    ProminentCountdownCard(event: .init(title: "Product Launch",
                                        startDate: Date().addingTimeInterval(-2000),
                                        endDate: Date().addingTimeInterval(7200),
                                        isAllDay: false,
                                        color: .blue))
}
