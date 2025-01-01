//
//  EventList.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import SwiftUI
import HowLongLeftKit
import ScalingHeaderScrollView

struct EventListView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var keyEvent: Event
    var upcomingEvents: [Event]
    var inProgressEvents: [Event]
    
    var eventTitle: String = "Upcoming Event"
    var infoText: String = "Starts in 2 hours"
    
    @State var progress: CGFloat = 1
    @State var collapseProgress: CGFloat = 0
    @State var scrollProgress: CGFloat = 0
    
    func getBackgroundColor(event: Event) -> Color {
        collapseProgress >= 1.0 ? Color(uiColor: .secondarySystemBackground) : (colorScheme == .light ? Color.cyan : Color(uiColor: .systemBackground))
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScalingHeaderScrollView(header: {
                    EventListHeader(keyEvent: keyEvent, geometry: geometry, collapseProgress: collapseProgress, backgroundColor: getBackgroundColor(event: keyEvent))
                }, content: {
                    
                        EventListContent()
                        
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical)
                    .background(Color(uiColor: colorScheme == .light ? .systemBackground : .secondarySystemBackground))
                    .frame(maxWidth: .infinity, minHeight: 1000)
                })
                .height(min: 0, max: 450)
                .setHeaderSnapMode(.afterFinishAccelerating)
                .collapseProgress($collapseProgress)
                .background {
                    Color(getBackgroundColor(event: keyEvent))
                        .edgesIgnoringSafeArea(.all)
                }
                .edgesIgnoringSafeArea(.top)
                .navigationTitle("Events")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar((collapseProgress == 1) ? .visible : .hidden, for: .navigationBar)
                //.scrollIndicators((collapseProgress == 1) ? .visible : .hidden)
            }
        }
    }
}

struct EventRowView: View {
    let eventName: String
    let eventDate: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(eventName)
                .font(.headline)
            Text(eventDate)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(keyEvent: .example, upcomingEvents: [], inProgressEvents: [])
            .previewLayout(.fixed(width: 400, height: 800))
    }
}
