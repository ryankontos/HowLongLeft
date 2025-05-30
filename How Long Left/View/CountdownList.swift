//
//  CountdownList.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI
import FluidGradient

struct CountdownList: View {
    var events: [HLLEventViewModel]
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var hasAppeared = false
    
    var background: Color {
        return colorScheme == .dark ? .black : .white
    }
    
    var colours: [Color] {
        return events.map { $0.color }
    }
    
    var coloursWithBackground: [Color] {
        return colours + [background]
    }
    
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            FluidGradient(blobs: colours,
                          highlights: coloursWithBackground,
                          speed: 0.2,
                          blur: 0.75)
            
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 19) {
                        ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                            NavigationLink(destination: {
                                EventDetailView(event: event)
                                    
                            }, label: {
                                CountdownCard(event: event)
                                    .matchedTransitionSource(id: event.id, in: namespace)
                                    .opacity(hasAppeared ? 1 : 0)
                                    .offset(y: hasAppeared ? 0 : 20)
                                    .animation(
                                        .easeOut(duration: 0.45)
                                            .delay(Double(index) * 0.07),
                                        value: hasAppeared
                                    )
                            })
                            .buttonStyle(ImmediateHighlightButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                .navigationTitle("Countdowns")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    hasAppeared = true
                }
            }
        }
    }
}

#Preview {
    CountdownList(events: [
        .init(title: "Design Presentation",
              start: Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: .now)!,
              end:   Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: .now)!,
              calendar: "Work",
              color: .red),
        .init(title: "Dentist Appointment",
              start: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: .now)!,
              end:   Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: .now)!,
              calendar: "Home",
              color: .blue),
        .init(title: "Anniversary Dinner",
              start: Calendar.current.date(from: .init(year: 2025, month: 4, day: 24, hour: 19))!,
              end:   Calendar.current.date(from: .init(year: 2025, month: 4, day: 24, hour: 22))!,
              calendar: "Friends",
              color: .yellow),
        .init(title: "Family Reunion",
              start: Calendar.current.date(from: .init(year: 2025, month: 4, day: 28, hour: 13))!,
              end:   Calendar.current.date(from: .init(year: 2025, month: 4, day: 28, hour: 17))!,
              calendar: "Family",
              color: .green)
    ])
}

struct ImmediateHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.3) : Color.clear)
            .cornerRadius(8)
            .animation(.easeInOut(duration: 0.0), value: configuration.isPressed)
    }
}
