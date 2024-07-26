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
                HStack(alignment: .center, spacing: 7) {
                    
                    if settings.showIndicatorDot {
                        
                        Circle()
                            .foregroundStyle(calendarSource.getColor(calendarID: event.calendarID))
                            .frame(width: 7.5)
                            .opacity(0.9)
                        
                    }
                    
                    Text(getStatusItemText(event: event, at: date))
                        .lineLimit(1)
                        .monospacedDigit()
                        .id(event.id)
                      
                }
            } else {
                Image(systemName: "clock")
                    .renderingMode(.template)
            }
        }
        .foregroundColor(menuConfiguration.getColor())
        .transaction { transaction in
            transaction.animation = nil
        }
        
       
       
    }
    
    private func truncatedTitle(_ fullText: String) -> String {
        let maxCharacters = Int(settings.titleLengthLimit)
        guard fullText.count > maxCharacters else { return fullText }
        
        let start = fullText.prefix(maxCharacters / 2)
        let end = fullText.suffix(maxCharacters / 2)
        return "\(start)...\(end)"
    }
    
    private func getEvent(at date: Date) -> Event? {
        
        guard let point = pointStore.getPointAt(date: date) else { return nil }
        
        if let selected = selectedManager.getAllStoredEvents().first, let id = selected.eventID {
            if let event = point.allEvents.first(where: { $0.eventID == id }) {
                return event
            }
        }
        
       
        let rule = SingleEventFetchRule(rawValue: Int(settings.eventFetchRule))!
        return point.fetchSingleEvent(accordingTo: rule)
    }
    
    private func getStatusItemText(event: Event, at date: Date) -> String {
        let countdownText = countdown(to: event.countdownDate(at: date), from: date, showSeconds: true)
        var statusText = event.status(at: date) == .upcoming ? "in \(countdownText)" : countdownText
        
        if settings.showTitles {
            statusText = "\(truncatedTitle(event.title)): \(statusText)"
        }
        
        return statusText
    }
    
    private func countdown(to date: Date, from currentDate: Date, showSeconds: Bool) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = showSeconds ? [.hour, .minute, .second] : [.hour, .minute]
        formatter.zeroFormattingBehavior = [.pad]
        
        guard date > currentDate else { return "00:00:00" }
        
        return formatter.string(from: currentDate, to: date) ?? "00:00:00"
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

