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
    @EnvironmentObject var calendarSource: CalendarSource
    
    var body: some View {

        if let currentPoint = pointStore.currentPoint, let _ = currentPoint.fetchSingleEvent(accordingTo: .soonestCountdownDate) {
            
            CalendarEventListView(calendarEventListProvider: .init(pointStore: pointStore))
            
        } else {
            Text("No events")
        }
        
       
                
    }
}
