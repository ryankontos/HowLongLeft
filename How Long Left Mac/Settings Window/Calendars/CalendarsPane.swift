//
//  CalendarsPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import HowLongLeftKit
import SwiftUI

struct CalendarsPane: View {
    @EnvironmentObject var calPrefs: CalendarSettingsStore

    var contexts: Set<String>

    var showCalendarsWithContexts: Set<String>?

    var body: some View {
        Form {
            Section("Enabled Calendars") {
                CalendarsListView()
            }
        }

        .formStyle(.grouped)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu("Set All", systemImage: "slider.horizontal.3") {
                    Button("Set All Menu & Status Bar") {
                        updateAllContexts(option: .full)
                    }

                    Button("Set All Menu Only") {
                        updateAllContexts(option: .menuOnly)
                    }

                    Button("Set All Off") {
                        updateAllContexts(option: .off)
                    }
                }
            }
        }
    }

    func updateAllContexts(option: Option) {
        switch option {
        case .full:

            calPrefs.batchUpdateContexts(addContextIDs: [HLLStandardCalendarContexts.app.rawValue, MacCalendarContexts.statusItem.rawValue])

        case .menuOnly:
            calPrefs.batchUpdateContexts(addContextIDs: [HLLStandardCalendarContexts.app.rawValue], removeContextIDs: [MacCalendarContexts.statusItem.rawValue])

        case .off:
            calPrefs.batchUpdateContexts(removeContextIDs: [MacCalendarContexts.statusItem.rawValue, HLLStandardCalendarContexts.app.rawValue])
        }
    }

    public enum Option: String, CaseIterable, Identifiable {
        case full = "Menu & Status Bar"
        case menuOnly = "Menu Only"
        case off = "Off"

        var id: String {
            self.rawValue
        }
    }
}

#Preview {
    let container = MacDefaultContainer(id: "MacPreview")

    CalendarsPane(contexts: [HLLStandardCalendarContexts.app.rawValue])
        .environmentObject(container.calendarPrefsManager)
}
