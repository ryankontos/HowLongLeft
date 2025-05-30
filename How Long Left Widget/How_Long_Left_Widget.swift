//
//  How_Long_Left_Widget.swift
//  How Long Left Widget
//
//  Created by Ryan on 22/9/2024.
//

import HowLongLeftKit
import SwiftUI
import WidgetKit

@MainActor
struct Provider: @preconcurrency AppIntentTimelineProvider {
    func recommendations() -> [AppIntentRecommendation<HLLWidgetConfigurationIntent>] {
        [.init(intent: .init(), description: "Main")]
    }

    typealias Intent = HLLWidgetConfigurationIntent
    typealias Entry = TimePointEntry

    @MainActor let defaultContainer: HLLCoreServicesContainer
    @MainActor let widgetManager: WidgetTimePointManager

    @MainActor
    init() {
        self.defaultContainer = HLLCoreServicesContainer(id: "iOSWidget")
        self.widgetManager = WidgetTimePointManager(eventCache: defaultContainer.eventCache)
    }

    func placeholder(in _: Context) -> TimePointEntry {
        TimePointEntry(date: Date(), timePoint: .makeEmpty(), configuration: HLLWidgetConfigurationIntent())
    }

    func snapshot(for configuration: HLLWidgetConfigurationIntent, in _: Context) async -> TimePointEntry {
        let currentPoint = await widgetManager.timePointStore.currentPoint ?? .makeEmpty()
        return TimePointEntry(date: Date(), timePoint: currentPoint, configuration: configuration)
    }

    func timeline(for configuration: HLLWidgetConfigurationIntent, in _: Context) async -> Timeline<TimePointEntry> {
        var entries: [TimePointEntry] = []

        // Generate entries from the widget manager using its timeline conversion logic
        let timePointEntries = await widgetManager.generateTimelineEntries()

        // Convert timePointEntries to SimpleEntry objects for the WidgetKit timeline
        for timePointEntry in timePointEntries {
            
            let event = timePointEntry.timePoint.fetchSingleEvent(accordingTo: .inProgressOnly)
            
            print("Adding entry for \(timePointEntry.date.formatted(date: .numeric, time: .shortened)), event: \(event?.title ?? "No Event")")
            let entry = TimePointEntry(date: timePointEntry.date, timePoint: timePointEntry.timePoint, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct How_Long_Left_WidgetEntryView: View {
    var entry: Provider.Entry

    // Get widget size
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let event = entry.timePoint.fetchSingleEvent(accordingTo: .inProgressOnly) {
            platformSpecificView(displayDate: entry.date, event: event)
        } else {
            Text("No Events")
        }
    }

    @ViewBuilder
    private func platformSpecificView(displayDate: Date, event: HLLCalendarEvent) -> some View {
        #if os(iOS)
        Widget_EventView(displayDate: displayDate, progress: 0.2, event: event)
        #elseif os(watchOS)
        WatchCircularWidgetView(displayDate: displayDate, event: event)
        #endif
    }
}

struct How_Long_Left_Widget: Widget {
    let kind: String = "How_Long_Left_Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: HLLWidgetConfigurationIntent.self, provider: Provider()) { entry in
            How_Long_Left_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies(platformSupportedFamilies())
    }

    private func platformSupportedFamilies() -> [WidgetFamily] {
        #if os(iOS)
        return [.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryCircular]
        #elseif os(macOS)
        return [.systemSmall, .systemMedium, .systemLarge]
        #elseif os(watchOS)
        return [.accessoryRectangular, .accessoryInline, .accessoryCircular]
        #endif
    }
}

// MARK: - Platform-Specific Customisation

#if os(watchOS)
struct WatchCircularWidgetView: View {
    let displayDate: Date
    let event: HLLCalendarEvent

    var body: some View {
        Text("watchOS Circular Progress") // Replace with actual implementation
    }
}
#endif

