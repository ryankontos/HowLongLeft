//
//  StatusItemContentView.swift
//  How Long Left Mac
//
//  Created by Ryan on 11/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct StatusItemContentView: View {
    
    @EnvironmentObject var pointStore: TimePointStore
    
    var body: some View {
        if let event = getEvent() {
            Text(event.title)
        } else {
            Image(systemName: "clock")
        }
        
       
    }
    
    func getEvent() -> Event? {
        
        return pointStore.getPointAt(date: Date())?.fetchSingleEvent(accordingTo: .preferInProgress)
        
    }
    
}

#Preview {
    StatusItemContentView()
}

