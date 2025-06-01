//
//  GeneralPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Defaults
import HowLongLeftKit
import Settings
import SwiftUI

struct GeneralPane: View {
    @EnvironmentObject var filteringManager: EventFilterDefaultsManager

    @EnvironmentObject var listSettingsModel: EventListSettingsManager

    var body: some View {
        Form {
            Section {
                Toggle(isOn: .constant(true)) {
                    Text("Launch at Login!")
                }
            }

            Section("Main Menu") {
                Toggle(isOn: $listSettingsModel.showInProgress) {
                    Text("Show In-Progress Events Section")
                }

                if listSettingsModel.showInProgress {
                    Toggle(isOn: $listSettingsModel.showInProgressWhenEmpty) {
                        Text("Show When Empty")
                    }
                }
            }

            Section {
                Toggle(isOn: $listSettingsModel.showUpcoming) {
                    Text("Show Upcoming Events")
                }

                if listSettingsModel.showUpcoming {
                    Toggle(isOn: $listSettingsModel.showEmptyUpcomingDays) {
                        Text("Show Days Without Events")
                    }

                    Stepper(value: $listSettingsModel.upcomingDaysLimit) {
                        HStack {
                            Text("Limit")

                            Spacer()

                            Text("\(listSettingsModel.upcomingDaysLimit) Day\(listSettingsModel.upcomingDaysLimit == 1 ? "" : "s")")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if listSettingsModel.showUpcoming && listSettingsModel.showInProgress {
                Section {
                    Picker("Sort Events", selection: $listSettingsModel.sortMode.animation()) {
                        Text("On Now First")
                            .tag(EventListSortMode.onNowFirst)
                        Text("Chronologically")
                            .tag(EventListSortMode.chronological)
                        Text("Upcoming First")
                            .tag(EventListSortMode.upcomingFirst)
                    }
                }
            }

            Section("All-Day Events") {
                Defaults.Toggle("Show All-Day Events", key: filteringManager.configuration.allowAllDayKey)

                /*Toggle(isOn: .constant(true), label: {
                 Text("Show In On Now ")
                 }) */
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 500)
    }
}

#Preview {
    let container = DefaultContainer()

    return GeneralPane()
        .environmentObject(container.calendarPrefsManager)
}
