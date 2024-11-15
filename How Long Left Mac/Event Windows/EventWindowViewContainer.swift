//
//  EventWindowViewContainer.swift
//  How Long Left Mac
//
//  Created by Ryan on 14/11/2024.
//

import SwiftUI
import HowLongLeftKit

struct EventWindowViewContainer: View {
    
    var event: Event
    var calendarSource: CalendarSource
    @ObservedObject var eventWindow: EventWindow
    
    var body: some View {
        
        VStack {
            
            EventWindowView(event: event, calendarSource: calendarSource)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1.0, contentMode: .fill)
                .environmentObject(eventWindow)
               
        }
        .edgesIgnoringSafeArea(.all)
    }
}
/*
#Preview {
    EventWindowViewContainer(event: .example)
}
*/
