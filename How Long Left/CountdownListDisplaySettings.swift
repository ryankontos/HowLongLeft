//
//  CountdownListDisplaySettings.swift
//  How Long Left
//
//  Created by Ryan on 31/5/2025.
//

import SwiftUI
import HowLongLeftKit

struct CountdownListDisplaySettings: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: CalendarSettingsStore
    
    @EnvironmentObject var eventSource: CompositeEventCache
    
    @State private var showCalendarEvents = false
    
   
    
    var body: some View {
        NavigationStack {
            List {
                Toggle(isOn: $eventSource.showCalendarEvents.animation()) {
                    Text("Show Calendar Events")
                }
                
                if eventSource.showCalendarEvents {
                    Section("Calendars") {
                        ForEach(manager.calendarItems) { calendar in
                            ToggleCalendarStateView(calendarInfo: calendar, toggleContext: HLLStandardCalendarContexts.app.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Calendar Events")
            
        }
    }
}

#Preview {
    let core = HLLCoreServicesContainer(id: "App")
    
    return CountdownListDisplaySettings()
        .environmentObject(core.calendarPrefsManager)
}
