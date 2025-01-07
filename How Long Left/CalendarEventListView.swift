//
//  CalendarEventListView.swift
//  How Long Left
//
//  Created by Ryan on 3/1/2025.
//

import SwiftUI
import HowLongLeftKit

struct CalendarEventListView: View {
    @ObservedObject var calendarEventListProvider: CalendarEventListProvider
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) {
                    ForEach(calendarEventListProvider.eventList) { eventContainer in
                        createCard(with: eventContainer)
                            .drawingGroup()
                            .shadow(radius: 5)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground)) // Set view background
            .navigationTitle("How Long Left")
        }
    }
    
    func createCard(with container: CalendarEventContainer) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundStyle(Color(UIColor.secondarySystemBackground)) // Card background
            
            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 7, height: 7)
                        .foregroundColor(Color(container.calendar.color))
                    Text("\(container.calendar.title)")
                        .foregroundColor(.primary)
                    Spacer()
                }
                .font(.system(size: 14, weight: .medium))
                Divider()
                    .frame(height: 1.3)
                    .background(Color.primary.opacity(0.2))
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(container.event?.title ?? "No Event")")
                        Text("50 minutes remaining")
                            //.opacity(0.6)
                            .foregroundStyle(Color(container.calendar.color))
                    }
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
                    .font(.system(size: 22, weight: .semibold))
                    
                    Spacer()
                }
                .padding(.top, 5)
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    let defaultContainer = HLLCoreServicesContainer(id: "iOSApp")
    CalendarEventListView(calendarEventListProvider: MockCalendarEventListProvider( timePointStore: defaultContainer.pointStore))
}
