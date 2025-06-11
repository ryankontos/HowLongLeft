//
//  WatchEventInfoView.swift
//  How Long Left watchOS Watch App
//
//  Created by Ryan on 6/6/2025.
//

import SwiftUI
import HowLongLeftKit

struct WatchEventInfoView: View {
    
    @ObservedObject var event: HLLEvent
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                Text(event.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                if let location = event.locationName, !location.isEmpty {
                    Text(location)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 4) {
                    HStack {
                        Text("Starts:")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(event.startDate.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 13))
                    }
                    
                    HStack {
                        Text("Ends:")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(event.endDate.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 13))
                    }
                }
                .padding(.top, 5)
                .padding(.horizontal)
                
                Divider()
                
                VStack(spacing: 10) {
                    Button("📌 Pin to Complication") {
                        // Dummy action
                    }
                    .buttonStyle(.bordered)

                    Button("🗑 Delete") {
                        // Dummy action
                    }
                    .buttonStyle(.bordered)

                    Button("🙈 Hide") {
                        // Dummy action
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
        }
        .containerBackground(event.color, for: .tabView)
    }
}

#Preview {
    TabView{
        WatchEventInfoView(event: .makeExampleEvent(title: "Team Meeting", end: Date() + 3600, color: .blue))
    }
}
