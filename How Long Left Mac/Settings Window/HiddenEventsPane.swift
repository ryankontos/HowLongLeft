//
//  HiddenEventsPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 22/6/2024.
//

import SwiftUI
import HowLongLeftKit

struct HiddenEventsPane: View {

    @EnvironmentObject var storedEventManager: StoredEventManager
    @EnvironmentObject var calendarSource: CalendarSource

    let formatter = DateFormatterUtility()

    var body: some View {

        Group {
            
            let hidden = storedEventManager.getAllStoredEvents()
            
            if hidden.isEmpty {
                Text("No Hidden Events")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                hiddenEventsForm(hidden: hidden)
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus", action: {})
            }
        }
    }

    private func hiddenEventsForm(hidden: [StoredEventInfo]) -> some View {
        Form {
            Section("Hidden Events") {
                ForEach(hidden) { info in
                    HStack {
                        HStack(spacing: 9) {
                            Circle()
                                .frame(width: 8)
                                .foregroundStyle(calendarSource.getColor(calendarID: info.calendarID ?? "none"))

                            VStack(alignment: .leading) {
                                Text("\(info.title ?? "Unknown Title")")
                                    .lineLimit(1)
                                Text("\(formatter.getIntervalString(start: info.startDate ?? Date(), end: info.endDate ?? Date(), isAllDay: info.isAllDay, newLineForEnd: false))")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.trailing, 20)
                        }
                        Spacer()
                        Button("Unhide", action: {
                            withAnimation {
                                storedEventManager.removeEventFromStore(eventInfo: info)
                            }
                        })
                    }
                }
            }
            
        }
        .formStyle(.grouped)
       
        
        
    }
}

#Preview {
    
    let defaultContainer = MacDefaultContainer()
    
    
    
    return HiddenEventsPane()
        .environmentObject(defaultContainer.calendarReader)
        .environmentObject(defaultContainer.hiddenEventManager)
}
