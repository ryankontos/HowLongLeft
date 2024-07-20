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
    @EnvironmentObject var settings: StatusItemSettings
    
    @ObservedObject var model: StatusBarPaneModel
    
    @State var titleLimit: Int = 0
    
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
                   
                    Toggle("Show Event Titles", isOn: $model.showTitles)
                        
                    
                    if settings.showTitles {
                        Slider(value: $model.titleLimit, in: 5...50, step: 1, label: {
                            VStack(alignment: .leading) {
                                Text("Title Length Limit")
                                Text("\(Int(settings.titleLengthLimit)) Characters")
                                    .foregroundStyle(.secondary)
                            }
                            
                            
                        }, onEditingChanged: {_ in 
                            
                        })
                        .onChange(of: settings.titleLengthLimit, perform: { old in
                            let hapticManager = NSHapticFeedbackManager.defaultPerformer
                            hapticManager.perform(.alignment, performanceTime: .default)
                        })
                        
                    }
                    
                    
                   
                        
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
        .onAppear() {
            self.titleLimit = Int(settings.titleLengthLimit)
        }
        
        .navigationTitle("Status Bar")
        
    }
}



class StatusBarPaneModel: ObservableObject {
    
    init(settings: StatusItemSettings, store: StatusItemStore) {
        self.settings = settings
        self.showTitles = settings.showTitles
        self.store = store
        self.titleLimit = Double(Int(settings.titleLengthLimit))
    }
    
    var settings: StatusItemSettings
    
    var store: StatusItemStore
    
    @Published var showTitles: Bool {
        didSet {
            settings.showTitles = showTitles
            
            store.settingsStore.saveSettings(settings: settings)
            
        }
    }
    
    @Published var titleLimit: Double {
        
        didSet {
            settings.titleLengthLimit = Double(Int(titleLimit))
            store.settingsStore.saveSettings(settings: settings)
            
        }
        
    }
    
}
