//
//  EventList.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import HowLongLeftKit
import SwiftUI

struct EventList: View {
    @EnvironmentObject var pointStore: TimePointStore
    @EnvironmentObject var calendarSource: CalendarSource

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Example of using reusable CardView
                    CardView(
                        title: "Event",
                        subtitle: "10:00am - 11:00am",
                        timeRemaining: "00:00",
                        color: .blue
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 1)

                    CardView(
                        title: "Meeting",
                        subtitle: "1:00pm - 2:00pm",
                        timeRemaining: "01:00",
                        color: .green
                    )
                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 1)

                    // Add more cards as needed
                }
                .padding(.top, 30)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    EventList()
}
