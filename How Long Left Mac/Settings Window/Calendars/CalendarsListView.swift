//
//  CalendarsListView.swift
//  How Long Left Mac
//
//  Created by Ryan on 11/8/2024.
//

import HowLongLeftKit
import SwiftUI

struct CalendarsListView: View {
    @EnvironmentObject var calPrefs: EventFetchSettingsManager

    var body: some View {
        ForEach(calPrefs.calendarItems) { displayInfo in
            CalendarSettingPickerView(calendarInfo: displayInfo)
        }
    }
}
/*
 #Preview {
 CalendarsListView()
 }
 */
