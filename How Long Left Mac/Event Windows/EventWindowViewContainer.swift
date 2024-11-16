//
//  EventWindowViewContainer.swift
//  How Long Left Mac
//
//  Created by Ryan on 14/11/2024.
//

import HowLongLeftKit
import SwiftUI

struct EventWindowViewContainer: View {
    var calendarSource: CalendarSource
    var eventWindow: EventWindow

    var defaultContainer: MacDefaultContainer

    var pointStore: TimePointStore

    var selectedEventID: String?

    var body: some View {
        VStack {
            EventWindowView(eventWindow: eventWindow, defaultContainer: defaultContainer, pointStore: pointStore)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1.0, contentMode: .fill)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
/*
 #Preview {
 EventWindowViewContainer(event: .example)
 }
 */
