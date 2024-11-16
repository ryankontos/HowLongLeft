//
//  SettingsWindowContentView.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/6/2024.
//

import HowLongLeftKit
import SwiftUI
import SwiftUIIntrospect

struct SettingsWindowContentView: View {
    let container: MacDefaultContainer

    @State private var selection: MacSettingsTab = .general

    var body: some View {
        NavigationSplitView( sidebar: {
            List(selection: $selection) {
                ForEach(MacSettingsTab.allCases) { tab in
                    getTabButton(tab: tab)
                        .tag(tab)
                }
            }
            .frame(minWidth: 215, maxWidth: 215)
            .fixedSize(horizontal: true, vertical: false)
            .conditionalModifier {
                if #available(macOS 14.0, *) {
                    $0 .toolbar(removing: .sidebarToggle)
                } else {
                    $0
                }
            }

            .toolbar {
                // Force the toolbar to have a full height
                ToolbarItem(placement: .navigation) {
                    Spacer()
                        .frame(height: 20) // Adjust the height if needed
                }
            }
        }, detail: {
            NavigationStack {
                switch selection {
                case .general:
                    GeneralPane()

                        .toolbarRole(.editor)
                        .navigationTitle("General")
                        .environmentObject(container.eventListSettingsManager)
                        .environmentObject(container.calendarPrefsManager)

                case .calendars:
                    CalendarsPane(contexts: [HLLStandardCalendarContexts.app.rawValue])
                        .navigationTitle("Calendars")
                        .environmentObject(container.calendarPrefsManager)

                case .hidden:
                    HiddenEventsPane()
                        .navigationTitle("Hidden Events")
                        .environmentObject(container.calendarReader)
                        .environmentObject(container.calendarPrefsManager)
                        .environmentObject(container.hiddenEventManager)

                case .menuBar:

                    let settings = container.statusItemStore!.mainStatusItemContainer!.statusItemSettings
                    let store = container.statusItemStore!

                    StatusBarPane(model: StatusBarPaneModel(settings: settings, store: store))
                        .environmentObject(container.statusItemStore!.mainStatusItemContainer!.info)
                        .environmentObject(settings)
                        .environmentObject(store)
                        .environmentObject(container.statusItemStore!.mainStatusItemContainer!)
                        .environmentObject(container.calendarPrefsManager)

                case .customMenuBarItems:
                    ManageCustomMenusView()
                        .environmentObject(container.statusItemStore!)
                }
            }
        })

        .navigationSplitViewStyle(.automatic)
    }

    @ViewBuilder
    func getTabButton(tab: MacSettingsTab) -> some View {
        switch tab {
        case .general:

            Label("General", systemImage: "gear")

        case .calendars:
            Label("Calendars", systemImage: "calendar")

        case .hidden:
            Label("Hidden", systemImage: "eye.slash")

        case .menuBar:
            Label("Status Bar", systemImage: "rectangle.tophalf.filled")

        case .customMenuBarItems:
            Label("Custom Menus", systemImage: "star.fill")
        }
    }
}

#Preview {
    SettingsWindowContentView(container: MacDefaultContainer(id: "MacPreview"))
}

extension View {
    func conditionalModifier<T: View>(@ViewBuilder transform: (Self) -> T) -> some View {
        transform(self)
    }
}
