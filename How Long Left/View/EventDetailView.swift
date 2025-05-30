//
//  EventDetailView.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI
import MapKit
import Combine
import BezelKit
import FluidGradient
import HowLongLeftKit

struct EventDetailView: View {

    private var event: HLLEventViewModel

    @ObservedObject var progressManager: DurationProgressManager
    
    @Environment(\.colorScheme) var colorScheme

    init(event: HLLEventViewModel) {
        self.event = event
        self.progressManager = DurationProgressManager(start: event.startDate, end: event.endDate)
    }

    var body: some View {
        ZStack {
            //radialBackground

            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 50) {
                        
                        VStack() {
                            
                            
                            VStack(spacing: 10) {
                                
                                Text("IN-PROGRESS")
                                
                                    .font(.system(size: 15, weight: .semibold, design: .default))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .opacity(0.8)
                                    .foregroundStyle(.secondary)
                                
                                Text(event.title)
                                
                                    .font(.system(size: 32, weight: .semibold, design: .default))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .opacity(0.8)
                                
                            }
                               
                                
                            
                            Spacer()

                            CountdownRing(startDate: event.startDate, endDate: event.endDate, color: event.color, lineWidth: 7, fontSize: 50, fontWeight: .medium)
                                
                                
                            
                          
                            .shadow(radius: 7)
                            .frame(width: 260, height: 260)
                            
                            Spacer()

                            Text("\(progressManager.percentageString) Complete")
                                .font(.system(size: 19, weight: .regular))
                                .foregroundStyle(.secondary)
                        }
                        
                        .padding(.vertical, 0)
                        
                        .frame(height: geo.size.height * 0.55)
                        .padding(.top, 10)
                        
                        
                        

                        aboutCard
                            .padding(.horizontal)
                            .glassCardBackground(cornerRadius: 25)
                            .padding(.horizontal, 12)
                    }
                }
            }
            
        }
        .tint(event.color)
        .toolbar {
            ToolbarItem(placement: .automatic, content: {
                Button(action: {}, label: {
                    Image(systemName: "ellipsis.circle.fill")
                })
                .tint(.primary)
            })
        }
    }

    var background: Color {
        return colorScheme == .dark ? .black : .white
    }

    private var radialBackground: some View {
        FluidGradient(blobs: [event.color.opacity(0.5)],
                      highlights: [background, event.color.opacity(0.2)],
                      speed: 0.1,
                      blur: 0.75)
        .ignoresSafeArea()
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            infoRow(icon: "calendar.badge.clock",
                    title: "Starts",
                    value: event.startDate.formatted(date: .abbreviated, time: .shortened))

            Divider().background(Color.white.opacity(0.12))

            infoRow(icon: "flag.checkered",
                    title: "Ends",
                    value: event.endDate.formatted(date: .abbreviated, time: .shortened))

            Divider().background(Color.white.opacity(0.12))

            infoRow(icon: "clock.arrow.circlepath",
                    title: "Duration",
                    value: event.durationString)

            Divider().background(Color.white.opacity(0.12))

            infoRow(icon: "calendar",
                    title: "Calendar",
                    value: event.calendarName,
                    tint: event.color)

            if let location = event.locationName {
                Divider().background(Color.white.opacity(0.12))
                infoRow(icon: "mappin.and.ellipse",
                        title: "Location",
                        value: location,
                        linkAction: {})
            }

            if let notes = event.notes {
                Divider().background(Color.white.opacity(0.12))
                infoRow(icon: "note.text",
                        title: "Notes",
                        value: notes)
            }
        }
        .padding(22)
    }

    private func infoRow(icon: String,
                         title: String,
                         value: String,
                         tint: Color? = nil,
                         linkAction: (() -> Void)? = nil) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}


#Preview {
    NavigationStack {
        EventDetailView(
            event: .init(
                title: "Session 1 Recess",
                start: Date()-1000,
                end: Date()+1000,
                calendar: "Ryan Uni",
                color: .yellow
            )
        )
    }
}
