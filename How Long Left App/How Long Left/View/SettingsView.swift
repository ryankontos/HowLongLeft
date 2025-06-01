//
//  SettingsView.swift
//  How Long Left
//
//  Created by Ryan on 31/5/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                
                Section("General") {
                    
                    
                    NavigationLink(destination: {
                        CountdownListDisplaySettings()
                    }, label: {
                        SettingsRowView(sfSymbolName: "calendar", iconColour: .white, iconBackground: .blue, title: "Calendars")
                        
                        
                    })
                    
                }
               
                
                
            }
            .navigationTitle("Settings")
            //.navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
