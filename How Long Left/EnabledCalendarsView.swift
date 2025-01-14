//
//  EnabledCalendarsView.swift
//  How Long Left
//
//  Created by Ryan on 7/5/2024.
//

import EventKit
import HowLongLeftKit
import SwiftUI

@MainActor
struct EnabledCalendarsView: View {
    @EnvironmentObject var manager: CalendarSettingsStore

    var body: some View {
        NavigationStack {
            Form {
                ForEach($manager.calendarItems) { $cal in
                    ToggleCalendarStateView(calendarInfo: cal, toggleContext: HLLStandardCalendarContexts.app.rawValue)
                }
            }
        }
    }

    func getColor(from cal: EKCalendar?) -> Color {
        guard let col = cal?.cgColor else { return .primary }
        return Color(col)
    }
}

#Preview {
    
    let container = HLLCoreServicesContainer(id: "iOS")
    
    EnabledCalendarsView()
        .environmentObject(container.calendarPrefsManager)
}
