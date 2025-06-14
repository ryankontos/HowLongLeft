//
//  MenuEventListSection.swift
//  How Long Left Mac
//
//  Created by Ryan on 14/5/2024.
//

import FluidMenuBarExtra
import HowLongLeftKit
import SwiftUI

struct MenuEventListSection: View {
    var id: String
    var title: String?
    var info: String?
    var allDayEvents: [HLLEvent]
    var events: [HLLEvent]
    var forceProminence: Bool
    var mainMenuModel: WindowSelectionManager

    var statusItemPointStore: TimePointStore

    @ObservedObject var eventSelectionManager: StoredEventManager

    @EnvironmentObject var env: MainMenuEnvironment
    @EnvironmentObject var reader: CalendarSource
    @EnvironmentObject var eventInfoSource: StoredEventManager

    @EnvironmentObject var eventWindowManager: EventWindowManager

    var timerContainer: GlobalTimerContainer

    var body: some View {
        
        if let title {
           
            VStack(spacing: 6) {
                
                headerView(title: title, info: info)
                
                
               /* if events.isEmpty, allDayEvents.isEmpty {
                    Text("No Events")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 7)
                        .padding(.bottom, 5)
                } */
                
                if !events.isEmpty {
                    
                    ForEach(events, content: getSubmenuButton(for:))
                      //  .drawingGroup()
                    
                }

                if !allDayEvents.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(allDayEvents, content: getSubmenuButton(for:))
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    }
                }
            }
            
        }
    }

    private func headerView(title: String, info: String?) -> some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .opacity(0.9)
            Spacer()
            if let info {
                Text(info)
                    .opacity(0.9)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 5)
        .padding(.horizontal, 10)
        // .background(Color.red)
    }

    @ViewBuilder
    private func getSubmenuButton(for event: HLLEvent) -> some View {
        let buttonID = "\(id)-\(event.id)"
        let highlightColor = getColor(for: event)

        SubmenuButton(
            model: mainMenuModel,
            idForHover: buttonID,
            cornerRadius: event.isAllDay ? 5 : 5,
            padding: event.isAllDay ? 3 : 6,
            horizontalPadding: event.isAllDay ? 7 : 10,
            customHighlight: highlightColor,
            fill: highlightColor != nil,
            showChevron: !event.isAllDay,
            submenuContent: {
                AnyView(MenuEventViewParent(event: event, statusItemPointStore: statusItemPointStore)
                            .environmentObject(eventInfoSource)
                            .environmentObject(reader)
                            .environmentObject(timerContainer)
                            .environmentObject(eventWindowManager)
                )
            },
            content: {
                EventMenuItemView(event: event, selectedManager: eventSelectionManager, timerContainer: timerContainer, forceProminent: forceProminence)
                    .id(event.id)
            },
            action: {
                withAnimation {
                    eventSelectionManager.addEventToStore(event: event, removeIfExists: true)
                }
            }
        )
        .id(event.id)
    }

    private func getColor(for event: HLLEvent) -> Color? {
        
        guard let event = event as? HLLCalendarEvent else { return nil }
        
        guard event.isAllDay, event.status() == .upcoming, !forceProminence else { return nil }
        guard let color = reader.lookupCalendar(withID: event.calendarID)?.color else { return .orange }
        return Color(color)
    }
}
