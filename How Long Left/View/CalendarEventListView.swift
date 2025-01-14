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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Namespace private var calendarEventList
    
    @State var showSettings: Bool = false
    
    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .compact ? 20 : 30
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 30)], spacing: 15) {
                    
                    // Events Section
                    Section {
                        ForEach(calendarEventListProvider.containersWithEvent) { eventContainer in
                            getCardNavigationLink(for: eventContainer)
                                .shadow(radius: 5)
                        }
                    }
                    
                    // Separator
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: 1)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 15)
                        .opacity(0.5)
                    
                    // No Events Section
                    Section {
                        ForEach(calendarEventListProvider.containersWithoutEvent) { eventContainer in
                            getCardNavigationLink(for: eventContainer)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 30)
            }
            .background(Color(UIColor.systemGroupedBackground)
                .padding(-50)
                .edgesIgnoringSafeArea(.all))
            .navigationTitle("In Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gear", action: {showSettings.toggle()})
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            EnabledCalendarsView()
                
        }
    }
    
    private func getCardNavigationLink(for container: CalendarEventContainer) -> some View {
        Group {
            if let event = container.event {
                NavigationLink(destination:
                                EventDetailView(event: event)
                    .navigationTransition(.zoom(sourceID: container.id, in: calendarEventList))) {
                    CalendarEventCardView(container: container)
                }
            } else {
                CalendarEventCardView(container: container)
            }
        }
        .matchedTransitionSource(id: container.id, in: calendarEventList)
    }
}

#Preview {
    let defaultContainer = HLLCoreServicesContainer(id: "iOSApp")
    CalendarEventListView(calendarEventListProvider: MockCalendarEventListProvider(timePointStore: defaultContainer.pointStore))
}
