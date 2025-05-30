//
//  EventPickerView.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/11/2024.
//

import HowLongLeftKit
import SwiftUI

struct EventPickerView: View {
    @Binding var selectedEvents: [HLLCalendarEvent]

    @ObservedObject var timePointStore: TimePointStore

    var groupFetcher: EventListGroupProvider

    init(selectedEvents: Binding<[HLLCalendarEvent]>, timePointStore: TimePointStore) {
        self._selectedEvents = selectedEvents

        self.timePointStore = timePointStore

        self.groupFetcher = EventListGroupProvider(settingsManager: EventPickerViewGroupFetcherSettingsProvider())
    }

    var body: some View {
        NavigationStack {
            if let point = timePointStore.currentPoint {
                eventList(from: point)
                    .navigationTitle("Choose an Event")
            } else {
                Text("No events")
            }
        }
    }

    @ViewBuilder func eventList(from: TimePoint) -> some View {
        let groups = groupFetcher.getGroups(from: from, selected: nil)

        List {
            ForEach(groups.headerGroups) { group in
                Section(header: Text(group.title ?? "")) {
                    ForEach(group.combinedEvents) { event in
                        Card_EventPickerView(event: event) {
                            selectedEvents = [event]
                        }
                        .padding(.vertical, 10)
                    }
                }
            }

            ForEach(groups.upcomingGroups) { group in
                Section(header: Text(group.title ?? "")) {
                    ForEach(group.combinedEvents) { event in
                        Card_EventPickerView(event: event) {
                            selectedEvents = [event]
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
        }
    }
}

#Preview {
    let container = MacDefaultContainer(id: "Mac")

    EventPickerView(selectedEvents: .constant([]), timePointStore: container.pointStore)
        .frame(width: 400, height: 500)
}
