//
//  SettingsView.swift
//  How Long Left
//
//  Created by Ryan on 7/5/2024.
//

import EventKit
import HowLongLeftKit
import SwiftUI
import Defaults

@MainActor
struct SettingsView: View {
    
    @EnvironmentObject var manager: CalendarSettingsStore
    @Default(.listShowEmptyCalendars) var showEmptyCalendars: Bool
    @Environment(\.dismiss) private var dismiss // Used to dismiss the view
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section {
                    Toggle("Show Empty Calendars", isOn: $showEmptyCalendars)
                }
                
                ForEach($manager.calendarItems) { $cal in
                    ToggleCalendarStateView(calendarInfo: cal, toggleContext: HLLStandardCalendarContexts.app.rawValue)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss() // Dismiss the view
                    }
                }
            }
        }
    }
}

#Preview {
    
    let container = HLLCoreServicesContainer(id: "iOS")
    
    SettingsView()
        .environmentObject(container.calendarPrefsManager)
}
