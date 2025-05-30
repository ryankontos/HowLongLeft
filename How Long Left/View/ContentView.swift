//
//  ContentView.swift
//  How Long Left
//
//  Created by Ryan on 27/4/2025.
//

import SwiftUI
import HowLongLeftKit

struct ContentView: View {
    
    @EnvironmentObject var pointStore: TimePointStore
    
    
    var body: some View {
        
        if let currentPoint = pointStore.currentPoint {
                CountdownList(events: currentPoint.inProgressEvents.map({ HLLEventViewModel(event: $0) }))
                
               
                
            
        } else {
            Text("No Events")
        }
        
        
    }
}


#Preview {
    ContentView()
}
