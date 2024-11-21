//
//  MenuEventViewParent.swift
//  How Long Left Mac
//
//  Created by Ryan on 17/6/2024.
//

import FluidMenuBarExtra
import HowLongLeftKit
import SwiftUI

struct MenuEventViewParent: View {
    @EnvironmentObject var menuEnv: MainMenuEnvironment
    @EnvironmentObject var calSource: CalendarSource
    @EnvironmentObject var windowManager: FMBEWindowProxy

    var event: Event

    var statusItemPointStore: TimePointStore

    init(event: Event, statusItemPointStore: TimePointStore) {
        self.event = event
        self.statusItemPointStore = statusItemPointStore
    }

    var body: some View {
        Group {
            if windowManager.isAttached {
                MenuEventView(event: event, statusItemPointStore: statusItemPointStore)
            } else {
                ScrollView {
                    Spacer()

                    Text("Detached")

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
