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
    @EnvironmentObject var pointStore: TimePointStore
    
    @State var showCustomEventSheet = false
    @State var showSettingsSheet = false
    @EnvironmentObject var customEventManager: UserEventSource
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var settingsDetent: PresentationDetent = .medium
    
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
    
    var events: [HLLEvent] {
        pointStore.currentPoint?.inProgressEvents ?? []
    }
    
    var body: some View {
        ZStack {
            
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 19) {
                        ForEach(events) { event in
                            NavigationLink(destination: EventDetailView(event: event), label: {
                                CountdownCard(event: event)
                             
                            })
                            .buttonStyle(.plain)
                          
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                .navigationTitle("Countdowns")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    hasAppeared = true
                    print(events.map { $0.title })
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showCustomEventSheet.toggle()
                        }) {
                            Image(systemName: "plus")
                                .foregroundStyle(.primary)
                        }
                    }
                    
                  
                        
                }
                
            }
        }
        
     
        .sheet(isPresented: $showCustomEventSheet, content: {
            
            CustomEventFormView() { title, startDate, endDate, isAllDay, color in
                
                customEventManager.add(title: title, start: startDate, end: endDate, color: color)
                
            }
        })
        
            
    }
    
}



struct ImmediateHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.3) : Color.clear)
            .cornerRadius(8)
            .animation(.easeInOut(duration: 0.0), value: configuration.isPressed)
    }
}
