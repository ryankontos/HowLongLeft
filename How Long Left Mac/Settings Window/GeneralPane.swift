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
    
    @EnvironmentObject var filteringManager: EventFetchSettingsManager
    
    @EnvironmentObject var listSettingsModel: EventListSettingsManager
    
    var body: some View {
        
        Form {
            
            Section {
                Toggle(isOn: .constant(true), label: {
                    Text("Launch at Login")
                })
            }
            
            Section("Main Menu") {
                
                Toggle(isOn: $listSettingsModel.showInProgress, label: {
                    Text("Show In-Progress Events Section")
                })
                
                if listSettingsModel.showInProgress {
                    
                    Toggle(isOn: $listSettingsModel.showInProgressWhenEmpty, label: {
                        Text("Show When Empty")
                    })
                    
                }
            }
            
            Section {
                
                
                Toggle(isOn: $listSettingsModel.showUpcoming, label: {
                    Text("Show Upcoming Events")
                })
                
                if listSettingsModel.showUpcoming {
                    
                    
                    Toggle(isOn: $listSettingsModel.showEmptyUpcomingDays, label: {
                        Text("Show Days Without Events")
                    })
                    
                    Stepper(value: $listSettingsModel.upcomingDaysLimit, label: {
                        HStack {
                            Text("Limit")
                            
                            
                            Spacer()
                            
                            
                            Text("\(listSettingsModel.upcomingDaysLimit) Day\(listSettingsModel.upcomingDaysLimit == 1 ? "" : "s")")
                                .foregroundStyle(.secondary)

                        }
                    })
                    
                    
                    
                }
                
                
            }
            
            if listSettingsModel.showUpcoming && listSettingsModel.showInProgress {
                
                Section {
                    
                    Picker("Sort Events", selection: $listSettingsModel.sortMode.animation(), content: {
                        Text("On Now First")
                            .tag(EventListSortMode.onNowFirst)
                        Text("Chronologically")
                            .tag(EventListSortMode.chronological)
                        Text("Upcoming First")
                            .tag(EventListSortMode.upcomingFirst)
                        
                    })
                    
                }
                
            }
        
            
            Section("All-Day Events") {
                
                Defaults.Toggle("Show All-Day Events", key: filteringManager.configuration.allowAllDayKey)
                
                Toggle(isOn: .constant(true), label: {
                    Text("Show In On Now ")
                })
                
            }
            
        }
        .formStyle(.grouped)
        //.frame(width: 450, height: 500)
        
    }
}

#Preview {
    let container = MacDefaultContainer()
    
    return GeneralPane()
        .environmentObject(container.calendarPrefsManager)
        .environmentObject(container.eventListSettingsManager)
}

