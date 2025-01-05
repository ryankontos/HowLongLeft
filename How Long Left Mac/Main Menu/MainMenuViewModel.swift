//
//  MainMenuViewModel.swift
//  How Long Left Mac
//
//  Created by Ryan on 9/11/2024.
//

import FluidMenuBarExtra
import Foundation
import HowLongLeftKit

class MainMenuEnvironment: ObservableObject {
    @Published var displayEvent: HLLEvent?
}

@MainActor
class MainMenuViewModel: @preconcurrency MenuSelectableItemsProvider {
    var pointStore: TimePointStore
    var selectedManager: StoredEventManager
    var listSettings: EventListSettingsManager
    lazy var eventListProvider = EventListGroupProvider(settingsManager: listSettings)

    func getItems() -> [String] {
        let groups = getEventGroups(at: Date())
        return groups.headerGroups.flatMap { group in
            group.events.map { getEventId(eventId: $0.id, groupId: group.title ?? "nil") }
        } + groups.upcomingGroups.flatMap { group in
            group.events.map { getEventId(eventId: $0.id, groupId: group.title ?? "nil") }
        } + OptionsSectionButton.allCases.map(\.rawValue)
    }

    func getEventId(eventId: String, groupId: String) -> String {
        "\(groupId)-(\(eventId)"
    }

    func getEventGroups(at date: Date) -> EventGroups {
        guard let currentPoint = pointStore.getPointAt(date: date) else { return .init(headerGroups: [], upcomingGroups: []) }
        return eventListProvider.getGroups(from: currentPoint, selected: nil)
    }

    init(timePointStore: TimePointStore, listSettings: EventListSettingsManager, selectedManager: StoredEventManager) {
        self.pointStore = timePointStore
        self.listSettings = listSettings
        self.selectedManager = selectedManager
    }
}
