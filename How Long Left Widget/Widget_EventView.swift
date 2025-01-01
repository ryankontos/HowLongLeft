//
//  Widget_EventView.swift
//  How Long Left
//
//  Created by Ryan on 22/11/2024.
//

import SwiftUI
import HowLongLeftKit
import WidgetKit

struct Widget_EventView: View {
    var displayDate: Date
    var progress: Double
    var event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 9) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(event.title)
                        .lineLimit(2)
                        .font(.system(size: 21, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary.opacity(0.8))
                        .truncationMode(.middle)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(event.endDate, style: .timer)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .contentTransition(.numericText())
                            .padding(.vertical, 5)
                            .opacity(0.9)
                            .multilineTextAlignment(.leading)
                    }
                }
                .layoutPriority(1001)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                ProgressCircle(
                    progress: progress,
                    lineWidth: 8,
                    trackColor: .gray.opacity(0.3),
                    progressColor: event.color.opacity(0.7),
                    isRounded: true,
                    progressType: .deplete
                ) {
                   /* Text("\(Int(progress * 100))")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .minimumScaleFactor(0.9)*/
                }
                .frame(minHeight: 30, maxHeight: 45)
            }
            .padding(.top, -5)
            .padding(.horizontal, 2.5)
            .padding(.bottom, 2.5)
            .layoutPriority(-1)
        }
        .padding(.top, 2)
        .containerBackground(for: .widget) {
            Color(.secondarySystemBackground)
        }
    }
}

#if os(iOS)
struct Widget_EventView_Previews: PreviewProvider {
    static var previews: some View {
        Widget_EventView(
            displayDate: Date(),
            progress: 0.2,
            event: .makeExampleEvent(
                title: "Event",
                start: Date(),
                end: Date().addingTimeInterval(5990)
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
#endif
