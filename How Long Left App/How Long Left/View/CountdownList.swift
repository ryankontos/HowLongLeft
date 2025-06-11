//
//  CountdownList.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI
import FluidGradient
import HowLongLeftKit

struct CountdownList: View {
    
    @EnvironmentObject private var pointStore: TimePointProviderWrapper
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showCustomEventSheet = false
    @State private var showSettingsSheet = false
    @State private var settingsDetent: PresentationDetent = .medium
    
    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    private var inProgressEvents: [HLLEvent] {
        pointStore.currentPoint?.inProgressEvents ?? []
    }
    
    private var upcomingEvents: [HLLEvent] {
        pointStore.currentPoint?.upcomingEvents ?? []
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Countdowns")
                .navigationBarTitleDisplayMode(.large)
                .background(backgroundColor.ignoresSafeArea())
                .navigationDestination(for: HLLEvent.self) { event in
                    EventDetailView(event: event)
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if !inProgressEvents.isEmpty {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(inProgressEvents) { event in
                        NavigationLink(value: event) {
                            CountdownCard(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
        else if pointStore.isReady() {
            NoEventsView()
        }
        else {
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview {
    CountdownList()
        .environmentObject(
            TimePointProviderWrapper(provider: DummyTimePointStore())
        )
}
