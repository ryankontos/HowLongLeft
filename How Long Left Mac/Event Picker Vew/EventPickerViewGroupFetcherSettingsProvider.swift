//
//  EventPickerViewGroupFetcherSettingsProvider.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/11/2024.
//

import Foundation
import HowLongLeftKit

class EventPickerViewGroupFetcherSettingsProvider: EventListSettingsFetcher {
    var showInProgress: Bool {
        true
    }

    var showInProgressWhenEmpty: Bool {
        false
    }

    var showUpcoming: Bool {
        true
    }

    var upcomingDaysLimit: Int {
        14
    }

    var showEmptyUpcomingDays: Bool {
        false
    }

    var sortMode: HowLongLeftKit.EventListSortMode {
        .onNowFirst
    }

    var showAllMultiDayEventDays: Bool {
        false
    }
}
