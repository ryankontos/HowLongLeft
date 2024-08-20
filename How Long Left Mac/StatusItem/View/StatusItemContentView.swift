//
//  StatusItemContentView.swift
//  How Long Left Mac
//
//  Created by Ryan on 11/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct StatusItemContentView: View {
    
    @Environment(\.self) var environment
    @EnvironmentObject var pointStore: TimePointStore
    @EnvironmentObject var menuConfiguration: MenuConfigurationInfo
    @EnvironmentObject var settings: StatusItemSettings
    @EnvironmentObject var calendarSource: CalendarSource
    @ObservedObject var selectedManager: StoredEventManager
    
    private var textGenerator: StatusTextGenerator {
        StatusTextGenerator(settings: settings)
    }
    
    var body: some View {
        TimelineView(.periodic(from: Self.previousSecondWithMillisecondZero, by: 1)) { context in
            content(for: context.date)
        }
        .padding(.horizontal, 4)
        .fixedSize(horizontal: true, vertical: true)
    }
    
    @ViewBuilder
    private func content(for date: Date) -> some View {
        Group {
            if settings.showCountdowns, let event = getEvent(at: date) {
                eventCountdownView(for: event, at: date)
            } else {
                Image(systemName: "clock")
                    .renderingMode(.template)
            }
        }
        .foregroundColor(menuConfiguration.getColor())
        .transaction { transaction in
           // transaction.animation = nil
        }
    }
    
    @ViewBuilder
    private func eventCountdownView(for event: Event, at date: Date) -> some View {
        HStack(alignment: .center, spacing: 7) {
            if settings.showIndicatorDot {
                Circle()
                    .foregroundStyle(calendarSource.getColor(calendarID: event.calendarID))
                    .frame(width: 7.5)
                    .opacity(0.9)
            }
            
            Text(textGenerator.getStatusItemText(for: event, at: date))
                .lineLimit(1)
                .monospacedDigit()
                .id(event.id)
        }
    }
    
    private func getEvent(at date: Date) -> Event? {
        guard let point = pointStore.getPointAt(date: date) else { return nil }
        
        if let selectedEvent = selectedManager.getAllStoredEvents().first,
           let selectedID = selectedEvent.eventID,
           let event = point.allEvents.first(where: { $0.eventID == selectedID }) {
            return event
        }
        
        let rule = SingleEventFetchRule(rawValue: Int(settings.eventFetchRule))!
        return point.fetchSingleEvent(accordingTo: rule)
    }
    
    static var previousSecondWithMillisecondZero: Date = {
        let currentDate = Date()
        let calendar = Calendar.current
        
        guard let previousSecondDate = calendar.date(byAdding: .second, value: -1, to: currentDate) else {
            fatalError("Failed to create the date with millisecond set to zero.")
        }
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: previousSecondDate)
        components.nanosecond = 0
        
        return calendar.date(from: components) ?? {
            fatalError("Failed to create the date with millisecond set to zero.")
        }()
    }()
}

#Preview {
    StatusItemContentView(selectedManager: StoredEventManager(domain: "Preview_SelectedManager", limit: 1))
}

