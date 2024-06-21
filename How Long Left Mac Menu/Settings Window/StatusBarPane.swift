//
//  StatusBarPane.swift
//  How Long Left Mac Menu
//
//  Created by Ryan on 21/6/2024.
//

import SwiftUI

struct StatusBarPane: View {
    var body: some View {
        
        Form {
            
           
             Section {
                 
                 Toggle("Show Event Title", isOn: .constant(true))
                 Toggle("Show Completion", isOn: .constant(true))
                 
                 
                 
             }
                
            
           
            
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 500)
        
    }
}

#Preview {
    StatusBarPane()
}
