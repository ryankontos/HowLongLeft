//
//  MainMenuContentView.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/5/2024.
//

import FluidMenuBarExtra
import HowLongLeftKit
import SwiftUI

struct MainMenuContentView: View {
    @EnvironmentObject var pointStore: TimePointStore
    @EnvironmentObject var settingsWindow: SettingsWindow
    @EnvironmentObject var windowManager: FMBEWindowProxy
    @EnvironmentObject var calendarSource: CalendarSource
    @EnvironmentObject var configInfo: MenuConfigurationInfo

    @State private var isScrolling = false

    var statusItemPointStore: TimePointStore

    var selectedManager: StoredEventManager
    var selectionManager: WindowSelectionManager
    var model: MainMenuViewModel

    @StateObject private var menuEnv = MainMenuEnvironment()
    @State private var displayEvent: HLLCalendarEvent?

    var body: some View {
        let groups = model.getEventGroups(at: Date())
        VStack {
            if !groups.isEmpty {
                titleView()
                eventGroupsView(groups: groups)
            } else {
                noEventsView()
            }
            bottomView()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .frame(minWidth: 315, maxWidth: 315, maxHeight: 480)
        .environmentObject(menuEnv)
    }

    @ViewBuilder
    private func titleView() -> some View {
        if let title = configInfo.getTitle() {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.vertical, 4)
                Spacer()
            }
            .padding(.horizontal, 10)
        }
    }

    @ViewBuilder
    private func noEventsView() -> some View {
        if calendarSource.calendarAccessDenied {
            MenuNoCalendarAccessView()
        } else {
            MenuNoEventsView()
        }
    }
    @ViewBuilder
    private func eventGroupsView(groups: EventGroups) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                renderEventGroupSections(groups.headerGroups, seperateAllDay: false)

                if !groups.headerGroups.isEmpty && !groups.upcomingGroups.isEmpty {
                    Divider()
                }

                renderEventGroupSections(groups.upcomingGroups, seperateAllDay: true)
                
            }

            .padding(.top, 10)
          
        }
        .onScrollPhaseChange { _, new in
            
            
            switch new {
            case .idle, .decelerating:
                selectionManager.setScrollLock(false)
            case .tracking, .interacting, .animating:
                selectionManager.setScrollLock(true)
            }

        }
        
        .onAppear {
            setupSelectionManager()
        }
     
    }

    @ViewBuilder
    private func renderEventGroupSections(_ groupSections: [TitledEventGroup], seperateAllDay: Bool) -> some View {
        ForEach(groupSections.indices, id: \.self) { index in
            let group = groupSections[index]

            let (events, allDay) = seperateAllDay
                ? (group.events, group.allDayEvents)
                : (group.combinedEvents, [])

            MenuEventListSection(
                id: group.title ?? "nil",
                title: group.title,
                info: group.info,
                allDayEvents: allDay,
                events: events,
                forceProminence: group.flags.contains(.prominentSection),
                mainMenuModel: selectionManager,
                statusItemPointStore: statusItemPointStore,
                eventSelectionManager: selectedManager,
                timerContainer: GlobalTimerContainer()
            )

            if index < groupSections.endIndex - 1 {
                Divider()
            }
        }
    }

    private func setupSelectionManager() {
        selectionManager.submenuManager = windowManager
        windowManager.window?.hoverManager = selectionManager
    }

    @ViewBuilder
    private func bottomView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.horizontal, 10)
                .padding(.bottom, 4)

            getSubmenuButton(
                title: "Settings...",
                shortcut: "⌘ ,",
                idForHover: OptionsSectionButton.settings.rawValue
            ) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    windowManager.window?.resignKey()
                    settingsWindow.open()
                }
            }

            getSubmenuButton(
                title: "Quit How Long Left",
                shortcut: "⌘ Q",
                idForHover: OptionsSectionButton.quit.rawValue
            ) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    NSApp.terminate(nil)
                }
            }
        }
    }

    private func getSubmenuButton(title: String, shortcut: String, idForHover: String, action: @escaping () -> Void) -> some View {
        SubmenuButton(
            model: selectionManager,
            idForHover: idForHover,
            padding: 4,
            content: {
                HStack {
                    Text(title)
                    Spacer()
                    Text(shortcut)
                        .foregroundColor(.secondary)
                        .font(.system(size: 12, weight: .regular))
                }
            },
            action: action
        )
    }
}
