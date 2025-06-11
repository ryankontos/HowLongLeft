//
//  CurrentCard.swift
//  How Long Left
//
//  Created by Ryan on 11/6/2025.
//

import SwiftUI
import Combine
import MapKit
import HowLongLeftKit

// MARK: - View

struct CurrentCard: View {
    @ObservedObject var event: HLLEvent

    @State private var showDetails = false

    var body: some View {


            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("HOME")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(alignment: .center, spacing: 7) {
                        VStack(alignment: .leading, spacing: 18) {
                            Text(event.title)
                                .font(.system(size: 26, weight: .semibold))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(event.locationName ?? "No Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .layoutPriority(1)

                        Spacer()

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
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.4)
                                .monospacedDigit()
                                .padding(.horizontal, 4)
                            }
                        )
                        .frame(width: 100, height: 100)
                    }
                }

                Spacer()

                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("Directions")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: { showDetails = true }) {
                        Text("Details")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
           
        
       
    }
}

struct CurrentEventCardView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentCard(event: .init(title: "Anniversary Dinner",
                                 startDate: Date().addingTimeInterval(-1000),
                                 endDate: Date().addingTimeInterval(999909),
                                 isAllDay: false,
                                 color: .yellow))
            .frame(height: 200)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
