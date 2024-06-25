//
//  StatusBarPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 22/6/2024.
//

import SwiftUI

struct StatusBarPane: View {
    
    @EnvironmentObject var store: StatusItemStore
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                
                
            }
            .formStyle(.grouped)
           // .frame(width: 450, height: 500)
            
        }
        
        .navigationTitle("Status Bar")
        
    }
}

#Preview {
    StatusBarPane()
}
