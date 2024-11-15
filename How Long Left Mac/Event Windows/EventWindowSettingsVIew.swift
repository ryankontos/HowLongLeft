//
//  EventWindowSettingsVIew.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/11/2024.
//

import SwiftUI

struct EventWindowSettingsView: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                Section(footer: Text("Configure the event window's appearance and behaviour.")) {
                    
                    NavigationLink("Event") {
                        ScrollView {
                            
                            VStack {
                                
                                
                            }

                        }
                    }
                    
                }
                
                Section {
                    
                    Toggle("Float on Top", isOn: .constant(true))
                    
                }
                
                Section {
                    
                    Toggle("Auto-Advance Events", isOn: .constant(true))
                    
                }
                
            }
            .background {
                Color(.windowBackgroundColor)
            }
            .background(ignoresSafeAreaEdges: .all)
            .formStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
                        
            }
           
        }
        .frame(width: 350, height: 350)
    }
}

#Preview {
    EventWindowSettingsView(isPresented: .constant(true))
}
