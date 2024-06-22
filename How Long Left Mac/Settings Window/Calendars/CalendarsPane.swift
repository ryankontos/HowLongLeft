//
//  CalendarsPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct CalendarsPane: View {
    
    @EnvironmentObject var calPrefs: EventFetchSettingsManager
    
    @State var selection = [String]()
    
    var body: some View {
        

        ZStack {
            Form {
                
                Section("Enabled Calendars") {
                    
                    ForEach($calPrefs.calendarItems) { $displayInfo in
                        
                        CalendarSettingPickerView(calendarInfo: displayInfo, toggleContext: "")
                        
                        
                        //.tint(Color(displayInfo.calendar.color))
                        
                    }
                    
                    
                }
               
                
            }
           
            
           
            .formStyle(.grouped)
           
            
            .frame(width: 450, height: 500)
           
            
            
        }
           
           
        
    }
    
   
}

#Preview {
    let container = MacDefaultContainer()
    
    return CalendarsPane()
        .environmentObject(container.calendarPrefsManager)
        
}
