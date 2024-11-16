//
//  EventWindowView.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/11/2024.
//

import HowLongLeftKit
import SwiftUI

struct EventWindowView: View {
    @ObservedObject var eventWindow: EventWindow
    @State private var showSettings = false
    var defaultContainer: MacDefaultContainer
    var pointStore: TimePointStore

    var body: some View {
        Group {
            if let event = eventWindow.getEvent() {
                CircularCountdownView(
                    eventWindow: eventWindow,
                    defaultContainer: defaultContainer,
                    pointStore: pointStore,
                    event: event
                )
            } else {
                Text("No Event")
            }
        }
        .background(controlButtons)
        .sheet(isPresented: $showSettings) {
            EventWindowSettingsView(
                isPresented: $showSettings,
                timePointStore: defaultContainer.pointStore
            )
            .environmentObject(eventWindow)
        }
        .onChange(of: showSettings) { _, new in
            eventWindow.toggleMaxSizeLock(enabled: new)
        }
    }

    private var controlButtons: some View {
        VStack {
            Spacer()
            HStack {
                IconButton(displayAsToggled: eventWindow.floating, systemName: eventWindow.floating ? "square.stack.3d.down.forward.fill" : "square.stack.3d.down.forward") {
                    eventWindow.floating.toggle()
                }
                .help("Keep on Top")

                Spacer()
                IconButton(displayAsToggled: false, systemName: "gearshape") {
                    showSettings = true
                }
                .help("Settings")
            }
            .padding(.horizontal, 7)
            .padding(.bottom, 10)
        }
    }
}
