//
//  How_Long_Left_Widget.swift
//  How Long Left Widget
//
//  Created by Ryan on 22/9/2024.
//

import HowLongLeftKit
import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    func recommendations() -> [AppIntentRecommendation<HLLWidgetConfigurationIntent>] {
        [.init(intent: .init(), description: "Main")]
    }

    typealias Intent = HLLWidgetConfigurationIntent

    typealias Entry = TimePointEntry

    let defaultContainer = HLLCoreServicesContainer(id: "iOSWidget")

    init() {
        widgetManager = WidgetTimePointManager(eventCache: defaultContainer.eventCache)
    }

    let widgetManager: WidgetTimePointManager

    func placeholder(in _: Context) -> TimePointEntry {
        TimePointEntry(date: Date(), timePoint: nil, configuration: HLLWidgetConfigurationIntent())
    }

    func snapshot(for configuration: HLLWidgetConfigurationIntent, in _: Context) async -> TimePointEntry {
        let currentPoint = widgetManager.timePointStore.currentPoint
        return TimePointEntry(date: Date(), timePoint: currentPoint, configuration: configuration)
    }

    func timeline(for configuration: HLLWidgetConfigurationIntent, in _: Context) async -> Timeline<TimePointEntry> {
        var entries: [TimePointEntry] = []

        // Generate entries from the widget manager using its timeline conversion logic
        let timePointEntries = widgetManager.generateTimelineEntries()

        // Convert timePointEntries to SimpleEntry objects for the WidgetKit timeline
        for timePointEntry in timePointEntries {
            let entry = TimePointEntry(date: timePointEntry.date, timePoint: timePointEntry.timePoint, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct How_Long_Left_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            if let timePoint = entry.timePoint {
                // Show the next upcoming event and countdown to it
                if let event = timePoint.fetchSingleEvent(accordingTo: .soonestCountdownDate) {
                    Text("\(event.title)")
                        .font(.headline)
                } else {
                    Text("No events")
                        .font(.headline)
                }
            } else {
                Text("No events available")
                    .font(.headline)
            }
        }
    }
}

struct How_Long_Left_Widget: Widget {
    let kind: String = "How_Long_Left_Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: HLLWidgetConfigurationIntent.self, provider: Provider()) { entry in
            How_Long_Left_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        #if os(iOS)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
        #elseif os(watchOS)
        .supportedFamilies([.accessoryRectangular])
        #endif
    }
}

#if os(iOS)

#Preview(as: .systemSmall) {
    How_Long_Left_Widget()
} timeline: {
    TimePointEntry(date: .now, timePoint: nil, configuration: .init())
    TimePointEntry(date: .now, timePoint: nil, configuration: .init())
}

#endif
