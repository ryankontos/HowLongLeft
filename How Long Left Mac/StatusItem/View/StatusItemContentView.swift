//
//  StatusItemContentView.swift
//  How Long Left Mac
//
//  Created by Ryan on 11/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct StatusItemContentView: View {
    
    @Environment(\.self) var environment
    
    @EnvironmentObject var pointStore: TimePointStore
    @EnvironmentObject var menuConfiguration: MenuConfigurationInfo
    
    
    var body: some View {
        
        Group {
            
            if let event = getEvent() {
                Text(event.title)
            } else {
                Image(systemName: "clock")
                    .renderingMode(.template)
                    .foregroundColor(menuConfiguration.getColor())
                    
            }
            
        }
       // .foregroundColor(menuConfiguration.getColor())
        
       
    }
    
    func getEvent() -> Event? {
        
        return pointStore.getPointAt(date: Date())?.fetchSingleEvent(accordingTo: .preferInProgress)
        
    }
    
}

#Preview {
    StatusItemContentView()
}

