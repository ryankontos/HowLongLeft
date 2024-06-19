//
//  GeneralPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import SwiftUI
import Settings
import Defaults
import HowLongLeftKit

struct GeneralPane: View {
    
    @EnvironmentObject var filteringManager: EventFilterDefaultsManager
    
    var body: some View {
        
        Form {
            
            Section {
                Toggle(isOn: .constant(true), label: {
                    Text("Launch at Login")
                })
            }
            
            Section("Main Menu") {
                
                Toggle(isOn: .constant(true), label: {
                    Text("Show \"On Now\" Section")
                })
                
                Toggle(isOn: .constant(true), label: {
                    Text("Show Upcoming Events")
                })
                
            }
            
            Section("All-Day Events") {
                
                Defaults.Toggle("Show All-Day Events", key: filteringManager.configuration.allowAllDayKey)
                
                Toggle(isOn: .constant(true), label: {
                    Text("Show In On Now ")
                })
                
            }
            
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 400)
        
    }
}

#Preview {
    GeneralPane()
}
