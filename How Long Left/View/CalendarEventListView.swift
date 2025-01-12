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
                            createCard(with: eventContainer)
                                .drawingGroup()
                                .shadow(radius: 5)
                        }
                    }
                    
                    // Separator
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: 1)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 10)
                        .opacity(0.5)
                    
                    // No Events Section
                    Section {
                        ForEach(calendarEventListProvider.containersWithoutEvent) { eventContainer in
                            createCard(with: eventContainer)
                                .drawingGroup()
                                .shadow(radius: 5)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("How Long Left")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gear", action: {
                        
                    })
                }
            }
        }
    }
    
    private func createCard(with container: CalendarEventContainer) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color(UIColor.secondarySystemBackground))
            
            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 7, height: 7)
                        .foregroundColor(Color(container.calendar.color))
                    Text(container.calendar.title)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .font(.system(size: 14, weight: .medium))
                
                Divider()
                    .frame(height: 1.3)
                    .background(Color.primary.opacity(0.2))
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(container.event?.title ?? "No Events")
                                .opacity(container.event == nil ? 0.5 : 1)
                            
                            if let event = container.event {
                                EventInfoText(
                                    event,
                                    stringGenerator: EventCountdownTextGenerator(
                                        showContext: true,
                                        postional: false
                                    )
                                )
                                .foregroundStyle(Color(container.calendar.color))
                            }
                        }
                        
                        if container.event != nil {
                            ProgressView(value: 0.5, total: 1.0)
                                .progressViewStyle(CalendarEventProgressStyle(container: container))
                                .frame(height: 8)
                                .cornerRadius(4)
                        }
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
        .opacity(container.event != nil ? 1 : 0.4)
    }
}

#Preview {
    let defaultContainer = HLLCoreServicesContainer(id: "iOSApp")
    CalendarEventListView(calendarEventListProvider: MockCalendarEventListProvider(timePointStore: defaultContainer.pointStore))
}

struct CalendarEventProgressStyle: ProgressViewStyle {
    let container: CalendarEventContainer
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(UIColor.systemGray5))
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(container.calendar.color))
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 200)
        }
    }
}
