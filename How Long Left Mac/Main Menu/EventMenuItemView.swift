//
//  EventMenuItemView.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/5/2024.
//

import SwiftUI
import HowLongLeftKit
import FluidMenuBarExtra
import Defaults

struct EventMenuItemView: View, Equatable {

    @Default(.showLocationsInMainMenu) var showLocations

    var timerContainer: GlobalTimerContainer
    var event: Event
    var forceProminent: Bool

    //@ObservedObject private var progressManager: EventProgressManager
    @ObservedObject private var selectedManager: StoredEventManager

    @EnvironmentObject private var source: CalendarSource

    private let dateFormatter = DateFormatterUtility()

    init(event: Event, selectedManager: StoredEventManager, timerContainer: GlobalTimerContainer, forceProminent: Bool) {
        self.event = event
        self.selectedManager = selectedManager
       
        self.timerContainer = timerContainer
        self.forceProminent = forceProminent
    }

    static func == (lhs: EventMenuItemView, rhs: EventMenuItemView) -> Bool {
        return lhs.event == rhs.event && lhs.forceProminent == rhs.forceProminent
    }

    var body: some View {
        
        
        VStack {
            HStack(spacing: 8) {
                if selectedManager.isEventStored(event: event) {
                    Image(systemName: "checkmark")
                }
                Circle()
                    .frame(width: 7)
                    .foregroundStyle(getColor().opacity(0.7))
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .font(.system(size: getProminence() ? 14 : 13, weight: .medium))
                    if getProminence() {
                        EventCountdownText(event)
                            .frame(height: 15)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    if let location = event.locationName, showLocations, getProminence() {
                        HStack(spacing: 3) {
                            Image(systemName: "location.fill")
                            Text(location).lineLimit(1)
                        }.foregroundStyle(.secondary)
                    }
                }.lineLimit(1)
                if !event.isAllDay {
                    Spacer()
                }
                if event.status() == .inProgress, getProminence() {
                    ProgressRingView(
                        progress: 0.5,
                        ringWidth: 4,
                        ringSize: 22,
                        color: getColor()
                    )
                }
            }
        }
    }

    private func getProminence() -> Bool {
        return forceProminent || event.status() != .upcoming
    }

    private func getColor() -> Color {
        Color(source.lookupCalendar(withID: event.calendarID)?.cgColor ?? .white)
    }
}


/*
#Preview {
    EventMenuListItem(
        event: Event(title: "Sample Event", start: Date(), end: Date().addingTimeInterval(1000)),
        selectedManager: StoredEventManager(),
        timerContainer: GlobalTimerContainer(),
        forceProminent: false
    )
}
*/
