//
//  ToggleCalendarStateView.swift
//  How Long Left
//
//  Created by Ryan on 9/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct ToggleCalendarStateView: View {
    @EnvironmentObject var manager: EventFilterDefaultsManager
    @ObservedObject var calendarInfo: CalendarInfo
    let toggleContext: String
    
    var body: some View {
        Toggle(isOn: Binding(
            get: {
                return manager.containsContext(calendarInfo: calendarInfo, contextID: toggleContext)
            },
            set: { newValue in
                if newValue {
                    manager.updateContexts(for: calendarInfo, addContextIDs: [toggleContext])
                } else {
                    manager.updateContexts(for: calendarInfo, removeContextIDs: [toggleContext])
                }
            }
        )) {
            
            HStack {
                Circle()
                    .frame(width: 9)
                    .foregroundStyle(getColor())
                Text(calendarInfo.title!)
            }
            
            
        }
    }
    
    func getColor() -> Color {
        
        if let cal = manager.getEKCalendar(for: calendarInfo) {
            return Color(cal.cgColor)
        }
        
        return .gray
        
    }
   
}

