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
   
    
    @State var collapseProgress: CGFloat = 0
    
    @State var scrollProgress: CGFloat = 0
    
    func getBackgroundColor(event: Event) -> Color {
        
        collapseProgress >= 1.0 ? Color(uiColor: .secondarySystemBackground) : (colorScheme == .light ? event.color : Color(uiColor: .systemBackground))
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            NavigationStack {
                ScalingHeaderScrollView(header: {
                    
                    EventListHeader(keyEvent: keyEvent, geometry: geometry, collapseProgress: collapseProgress, backgroundColor: getBackgroundColor(event: keyEvent))
                    
                  
                    
                }, content: {
                    
                   
                        
                        
                        ForEach(1..<50) { index in
                           
                            // Scrollable Content
                            VStack(spacing: 20) {
                                
                                HStack {
                                    
                                    Rectangle()
                                        .cornerRadius(5)
                                        .frame(width: 5)
                                        .foregroundStyle(.cyan)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(eventTitle)
                                            .font(.system(size: 20, weight: .semibold))
                                        Text(infoText)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .padding()
                                .background(Color(uiColor: .tertiarySystemFill))
                                .cornerRadius(15)
                                
                                .padding(.horizontal, 20)
                                
                                
                              
                            
                        }
                    }
                    .padding(.top)
                    .background(Color(uiColor: colorScheme == .light ? .systemBackground : .secondarySystemBackground)
                        .edgesIgnoringSafeArea(.bottom))
                    //.shadow(radius: 9)
                    // .cornerRadius(20)
                })
                .height(min: 0, max: 450)
                //.allowsHeaderGrowth()
                .setHeaderSnapMode(.afterFinishAccelerating)
                .collapseProgress($collapseProgress)
                .background {
                    Color(getBackgroundColor(event: keyEvent))
                        .edgesIgnoringSafeArea(.bottom)
                }
                .edgesIgnoringSafeArea(.top)
                .navigationTitle("Events")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar((collapseProgress == 1) ? .visible : .hidden, for: .navigationBar)
                .scrollIndicators((collapseProgress == 1) ? .visible : .hidden)
                
            }
            
        }
       // .preferredColorScheme(.light)
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
        //.background(Color.white)
        .cornerRadius(8)
       // .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(keyEvent: .example, upcomingEvents: [], inProgressEvents: [])
            // force preview to roughly iphone aspect ratio even though we're using catalyst to preview
            .previewLayout(.fixed(width: 400, height: 800))
    }
}
