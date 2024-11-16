//
//  WatchOS_Widget_Extension.swift
//  WatchOS Widget Extension
//
//  Created by Ryan on 24/9/2024.
//

import SwiftUI
import WidgetKit
/*
 struct Provider: AppIntentTimelineProvider {
 func placeholder(in context: Context) -> SimpleEntry {
 SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
 }

 func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
 SimpleEntry(date: Date(), configuration: configuration)
 }

 func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
 var entries: [SimpleEntry] = []

 // Generate a timeline consisting of five entries an hour apart, starting from the current date.
 let currentDate = Date()
 for hourOffset in 0 ..< 5 {
 let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
 let entry = SimpleEntry(date: entryDate, configuration: configuration)
 entries.append(entry)
 }

 return Timeline(entries: entries, policy: .atEnd)
 }

 func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
 // Create an array with all the preconfigured widgets to show.
 [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Example Widget")]
 }

 //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
 //        // Generate a list containing the contexts this widget is relevant in.
 //    }
 }

 struct SimpleEntry: TimelineEntry {
 let date: Date
 let configuration: ConfigurationAppIntent
 }

 struct WatchOS_Widget_ExtensionEntryView : View {
 var entry: Provider.Entry

 var body: some View {
 VStack {
 HStack {
 Text("Time:")
 Text(entry.date, style: .time)
 }

 Text("Favorite Emoji:")
 Text(entry.configuration.favoriteEmoji)
 }
 }
 }

 @main
 struct WatchOS_Widget_Extension: Widget {
 let kind: String = "WatchOS_Widget_Extension"

 var body: some WidgetConfiguration {
 AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
 WatchOS_Widget_ExtensionEntryView(entry: entry)
 .containerBackground(.fill.tertiary, for: .widget)
 }
 }
 }

 extension ConfigurationAppIntent {
 fileprivate static var smiley: ConfigurationAppIntent {
 let intent = ConfigurationAppIntent()
 intent.favoriteEmoji = "😀"
 return intent
 }

 fileprivate static var starEyes: ConfigurationAppIntent {
 let intent = ConfigurationAppIntent()
 intent.favoriteEmoji = "🤩"
 return intent
 }
 }

 #Preview(as: .accessoryRectangular) {
 WatchOS_Widget_Extension()
 } timeline: {
 SimpleEntry(date: .now, configuration: .smiley)
 SimpleEntry(date: .now, configuration: .starEyes)
 }
 */
