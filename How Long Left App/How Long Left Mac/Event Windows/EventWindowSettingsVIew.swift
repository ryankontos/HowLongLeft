//
//  EventWindowSettingsView.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/11/2024.
//

import HowLongLeftKit
import SwiftUI

struct EventWindowSettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var timePointStore: TimePointStore
    @EnvironmentObject var eventWindow: EventWindow

    @State private var showEventPicker = false
    @State private var events: [HLLCalendarEvent] = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Event Selection")
                        Spacer()

                            MenuButton(label:
                                        Text(eventWindow.getChosenEvent()?.title ?? "Automatic")
                                            .multilineTextAlignment(.trailing)) {
                                            
                                Button("Automatic", role: .destructive) {
                                    eventWindow.selectedEventID = nil
                                }
                                            
                                Button("Choose Event...") {
                                    showEventPicker = true
                                }
                                
                            }
                             .fixedSize()

                    }
                }
                Section {
                    Toggle("Float on Top", isOn: .constant(true))
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 350, height: 350)
        .sheet(isPresented: $showEventPicker) {
            EventPickerView(selectedEvents: $events, timePointStore: timePointStore)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showEventPicker = false
                        }
                    }
                }
                .frame(width: 350, height: 350)
        }
        .onChange(of: events) { _, new in
            eventWindow.selectedEventID = new.first?.eventIdentifier
            showEventPicker = false
        }
    }
}
