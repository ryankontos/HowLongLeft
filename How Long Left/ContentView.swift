//
//  ContentView.swift
//  How Long Left
//
//  Created by Ryan on 2/5/2024.
//

import SwiftData
import SwiftUI
import HowLongLeftKit

struct ContentView: View {
    
    @EnvironmentObject var pointStore: TimePointStore
    
    var body: some View {

        if let currentPoint = pointStore.currentPoint, let event = currentPoint.fetchSingleEvent(accordingTo: .soonestCountdownDate) {
            
            EventListView(keyEvent: event, upcomingEvents: currentPoint.upcomingEvents, inProgressEvents: currentPoint.inProgressEvents)
            
        } else {
            Text("No events")
        }
        
       
                
        
    }
}
