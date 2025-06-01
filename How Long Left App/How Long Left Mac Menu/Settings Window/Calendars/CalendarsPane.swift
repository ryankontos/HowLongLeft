//
//  CalendarsPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import HowLongLeftKit
import SwiftUI

struct CalendarsPane: View {
    @EnvironmentObject var calPrefs: EventFilterDefaultsManager

    @State private var selection = [String]()

    var body: some View {
        Form {
            Section("Enabled Calendars") {
                ForEach($calPrefs.calendarItems) { $displayInfo _ in
                    CalendarSettingPickerView(calendarInfo: displayInfo, toggleContext: "")

                    // .tint(Color(displayInfo.calendar.color))

                }
            }
        }
        .frame(minHeight: 400, maxHeight: 2_000)

        .formStyle(.grouped)

        .padding(.horizontal, 0)
        // .padding(.vertical, 40)
        .frame(width: 450)
    }
}

#Preview {
    let container = MacDefaultContainer()

    return CalendarsPane()
        .environmentObject(container.calendarPrefsManager)
}
