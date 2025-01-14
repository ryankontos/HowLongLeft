//
//  ToggleCalendarStateView.swift
//  How Long Left
//
//  Created by Ryan on 9/5/2024.
//

import HowLongLeftKit
import SwiftUI

struct ToggleCalendarStateView: View {
    @EnvironmentObject var manager: CalendarSettingsStore
    @ObservedObject var calendarInfo: CalendarInfo
    let toggleContext: String

    var body: some View {
        Toggle(isOn: Binding(
            get: {
                manager.containsContext(calendarInfo: calendarInfo, contextID: toggleContext)
            },
            set: { newValue in
                if newValue {
                    manager.updateContexts(for: calendarInfo, addContextIDs: [toggleContext], notify: true)
                } else {
                    manager.updateContexts(for: calendarInfo, removeContextIDs: [toggleContext], notify: true)
                }
            }
        )) {
            HStack {
                Circle()
                    .frame(width: 9)
                    .foregroundStyle(getColor())
                Text(calendarInfo.title!)
            }
        }
    }

    func getColor() -> Color {
        if let cal = manager.getHLLCalendar(for: calendarInfo) {
            return cal.color
        }

        return .gray
    }
}
