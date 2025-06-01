//
//  StatusItemContentView.swift
//  How Long Left Mac
//
//  Created by Ryan on 11/5/2024.
//

import HowLongLeftKit
import SwiftUI

struct StatusItemContentView: View {
    
    @Environment(\.self) var environment
    @EnvironmentObject var pointStore: TimePointStore
    @EnvironmentObject var menuConfiguration: MenuConfigurationInfo
    @EnvironmentObject var settings: StatusItemSettings
    @EnvironmentObject var calendarSource: CalendarSource
    @ObservedObject var selectedManager: StoredEventManager

    let eventProvider: StatusItemEventProvider
    
    private var textGenerator: StatusTextGenerator {
        StatusTextGenerator(settings: settings)
    }

    var body: some View {
        TimelineView(.periodic(from: Date.previousSecondWithMillisecondZero, by: 1)) { context in
            content(for: context.date)
        }
        .padding(.horizontal, 4)
        .fixedSize(horizontal: true, vertical: true)
        
        
    }

    @ViewBuilder
    private func content(for date: Date) -> some View {
        Group {
            if let event = eventProvider.getEvent(at: date) {
                eventCountdownView(for: event, at: date)
            } else {
                Image(systemName: "clock")
                    .renderingMode(.template)
            }
        }
        .foregroundColor(menuConfiguration.getColor())
        .transaction { _ in
            // transaction.animation = nil
        }
    }

    @ViewBuilder
    private func eventCountdownView(for event: HLLEvent, at date: Date) -> some View {
        HStack(alignment: .center, spacing: 7) {
            if settings.showIndicatorDot, let calEvent = event as? HLLCalendarEvent {
                Circle()
                    .foregroundStyle(calendarSource.getColor(calendarID: calEvent.calendarID))
                    .frame(width: 7.5)
                    .opacity(0.9)
            }

            Text(textGenerator.getStatusItemText(for: event, at: date))
                .lineLimit(1)
                .monospacedDigit()
                .id(event.id)
        }
    }

}
/*
#Preview {
    StatusItemContentView(selectedManager: StoredEventManager(domain: "Preview_SelectedManager", limit: 1))
}
*/
