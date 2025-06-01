//
//  How_Long_Left_WidgetLiveActivity.swift
//  How Long Left Widget
//
//  Created by Ryan on 22/9/2024.
//

#if !targetEnvironment(macCatalyst)
import ActivityKit
import SwiftUI
import WidgetKit

struct How_Long_Left_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct How_Long_Left_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: How_Long_Left_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here. Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension How_Long_Left_WidgetAttributes {
    fileprivate static var preview: How_Long_Left_WidgetAttributes {
        How_Long_Left_WidgetAttributes(name: "World")
    }
}

extension How_Long_Left_WidgetAttributes.ContentState {
    fileprivate static var smiley: How_Long_Left_WidgetAttributes.ContentState {
        How_Long_Left_WidgetAttributes.ContentState(emoji: "😀")
    }

    fileprivate static var starEyes: How_Long_Left_WidgetAttributes.ContentState {
        How_Long_Left_WidgetAttributes.ContentState(emoji: "🤩")
    }
}

#Preview("Notification", as: .content, using: How_Long_Left_WidgetAttributes.preview) {
    How_Long_Left_WidgetLiveActivity()
} contentStates: {
    How_Long_Left_WidgetAttributes.ContentState.smiley
    How_Long_Left_WidgetAttributes.ContentState.starEyes
}

#endif
