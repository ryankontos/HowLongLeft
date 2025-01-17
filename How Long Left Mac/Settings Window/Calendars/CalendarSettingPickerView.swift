//
//  CalendarSettingPickerView.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import Combine
import HowLongLeftKit
import SwiftUI

struct CalendarSettingPickerView: View {
    @EnvironmentObject var manager: CalendarSettingsStore
    @ObservedObject var calendarInfo: CalendarInfo

    @State private var selection: CalendarsPane.Option = .full
    private var selectionPublisher: PassthroughSubject<CalendarsPane.Option, Never>

    init(calendarInfo: CalendarInfo) {
        self.calendarInfo = calendarInfo

        self.selectionPublisher = PassthroughSubject<CalendarsPane.Option, Never>()
    }

    var body: some View {
        HStack {
            HStack {
                Circle()
                    .foregroundStyle(getColor())
                    .frame(width: 9)

                Text(calendarInfo.title!)
                    .lineLimit(1)
                Spacer()
            }

            Picker(selection: $selection, content: {
                ForEach(CalendarsPane.Option.allCases) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }, label: {
                EmptyView()
            })
            .frame(width: 160)
            .pickerStyle(.menu)
            .onChange(of: selection) { _, newValue in
               // //print("OC 5")
                selectionPublisher.send(newValue)
            }
        }
        .onAppear {
            updateSelectionFromItem()
        }
        .onReceive(calendarInfo.objectWillChange) { _ in
            updateSelectionFromItem()
        }
        .onChange(of: calendarInfo) { _, _ in
            updateSelectionFromItem()
        }
        .onReceive(selectionPublisher) { newSelection in
            switch newSelection {
            case .full:
                manager.updateContexts(for: calendarInfo, addContextIDs: [HLLStandardCalendarContexts.app.rawValue, MacCalendarContexts.statusItem.rawValue], notify: true)

            case .menuOnly:
                manager.updateContexts(for: calendarInfo, addContextIDs: [HLLStandardCalendarContexts.app.rawValue], removeContextIDs: [MacCalendarContexts.statusItem.rawValue], notify: true)

            case .off:
                manager.updateContexts(for: calendarInfo, removeContextIDs: [MacCalendarContexts.statusItem.rawValue, HLLStandardCalendarContexts.app.rawValue], notify: true)
            }
        }
    }

    func getColor() -> Color {
        if let cal = manager.getHLLCalendar(for: calendarInfo) {
            return cal.color
        }
        return .gray
    }

    func updateSelectionFromItem() {
        let containsApp = manager.containsContext(calendarInfo: calendarInfo, contextID: HLLStandardCalendarContexts.app.rawValue)
        let containsStatusItem = manager.containsContext(calendarInfo: calendarInfo, contextID: MacCalendarContexts.statusItem.rawValue)

        if containsApp && containsStatusItem {
            selection = .full
        } else if containsApp {
            selection = .menuOnly
        } else {
            selection = .off
        }
    }
}
