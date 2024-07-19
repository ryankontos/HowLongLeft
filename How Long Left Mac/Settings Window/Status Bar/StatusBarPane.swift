//
//  StatusBarPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 22/6/2024.
//

import SwiftUI

struct StatusBarPane: View {
    
    @EnvironmentObject var store: StatusItemStore
    @EnvironmentObject var config: StatusItemConfiguration
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                Section() {
                    Toggle("Show Event Countdowns In Status Bar", isOn: .constant(true))
                }
                
                Section("Events") {
                    
                    Toggle("Show In-Progress Events", isOn: .constant(true))
                    
                    Toggle("Show Upcoming Events", isOn: .constant(true))
                        
                }
    
                Section("Display Options") {
                   
                 /*   Toggle("Show Event Titles", isOn: $config.showTitle)
                        .onChange(of: config.showTitle, perform: { new in
                            
                            store.statusItemDataStore.saveItem(item: config)
                            
                        }) */
                    
                    Slider(value: .constant(10), in: 5...10, label: {
                        VStack(alignment: .leading) {
                            Text("Title Length Limit")
                            Text("10 Characters")
                                .foregroundStyle(.secondary)
                        }
                        
                        
                    })
                    
                    
                   
                        
                }
                
              
                
                Section {
                    
                    Picker("Countdown Style", selection: .constant(1), content: {
                        Text("Positional")
                            .tag(1)
                    })
                    
                    Toggle(isOn: .constant(true), label: {
                        Text("Show Seconds")
                    })
                }
                
                Section {
                    Toggle(isOn: .constant(true), label: {
                        Text("Show Completion Ring")
                    })
                    
                    Toggle(isOn: .constant(true), label: {
                        Text("Show Completion Percentage")
                    })
                }
                
               
                
                Section(content: {
                   
                    
                    Toggle(isOn: .constant(true), label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Hide When Empty")
                            Text("Hide the status item when it isn't displaying an event. You can relaunch How Long Left to temporarily make it visible.")
                                .font(.system(size: 12.5))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.trailing, 5)
                    })
                    
                }, header: {
                    Text("Advanced")
                }, footer: {
                    HStack {
                        
                        
                        Spacer()
                    }
                })
                
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
