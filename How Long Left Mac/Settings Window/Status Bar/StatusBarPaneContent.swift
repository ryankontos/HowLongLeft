//
//  StatusBarPaneContent.swift
//  How Long Left Mac
//
//  Created by Ryan on 11/8/2024.
//

import Foundation
import SwiftUI
import HowLongLeftKit

struct StatusBarPaneContent: View {
    
    @EnvironmentObject var statusItemContainer: StatusItemContainer
    @ObservedObject var model: StatusBarPaneModel
    @State private var showManageCals = false
    @State private var titleLimit: Int = 0
    
    var body: some View {

   
        
            Section() {
                Toggle("Show Countdown Text in Status Bar Item", isOn: $model.showCountdowns)
            }
        
        .onAppear {
            self.titleLimit = Int(model.titleLimit)
        }
        .sheet(isPresented: $showManageCals) {
            CalendarsPane(contexts: [MacCalendarContexts.statusItem.rawValue], showCalendarsWithContexts: [HLLStandardCalendarContexts.app.rawValue])
                .frame(width: 500, height: 350)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", action: {
                            showManageCals = false
                        })
                    }
                }
                
        }
            
            if model.showCountdowns {
                Section("Events") {
                    Toggle("Show In-Progress Events", isOn: $model.showCurrentEvents)
                    Toggle("Show Upcoming Events", isOn: $model.showUpcomingEvents)
                }
                
       
                Section("Appearance") {
                    Toggle("Show Event Titles", isOn: $model.showTitles)
                    if model.showTitles {
                        Slider(value: $model.titleLimit, in: 5...35, step: 1) {
                            VStack(alignment: .leading) {
                                Text("Title Length Limit")
                                Text("\(Int(model.titleLimit)) Characters")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onChange(of: model.titleLimit) { old in
                            let hapticManager = NSHapticFeedbackManager.defaultPerformer
                            hapticManager.perform(.alignment, performanceTime: .default)
                        }
                    }
                }
                
                Section {
                    Picker("Countdown Style", selection: .constant(1)) {
                        Text("Positional")
                            .tag(1)
                    }
                    Toggle(isOn: .constant(true)) {
                        Text("Show Seconds")
                    }
                }
                
                Section {
                    Toggle(isOn: $model.showIndicatorDot) {
                        Text("Show Calendar Indicator Dot")
                    }
                    Toggle(isOn: .constant(true)) {
                        Text("Show Completion Ring")
                    }
                    Toggle(isOn: $model.showPercentageText) {
                        Text("Show Completion Percentage")
                    }
                }
                
                Section(header: Text("Advanced")) {
                    Toggle(isOn: .constant(true)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Hide When Empty")
                            Text("Hide the status item when it isn't displaying an event. You can relaunch How Long Left to temporarily make it visible.")
                                .font(.system(size: 12.5))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.trailing, 5)
                    }
                }
            }
  
       
    }
}

