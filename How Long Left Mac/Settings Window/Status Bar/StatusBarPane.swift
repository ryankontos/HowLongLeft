//
//  StatusBarPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 22/6/2024.
//

import SwiftUI
import HowLongLeftKit

struct StatusBarPane: View {
    
    @EnvironmentObject var store: StatusItemStore
    @EnvironmentObject var config: StatusItemConfiguration
    @EnvironmentObject var settings: StatusItemSettings
    
    @ObservedObject var model: StatusBarPaneModel
    
    @State var titleLimit: Int = 0
    
    enum MultiTypeEventDisplayPickerOptions: Int, CaseIterable, Identifiable {
        
        case soonest
        case currentFirst
        case upcomingFirst
        
        var id: String {
            return String(self.rawValue)
        }
        
    }
    
    
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                Section() {
                    Toggle("Show Countdown Text in Status Bar", isOn: $model.showCountdowns)
                }
                
                if model.showCountdowns {
                    
                    Section("Events") {
                        
                        Toggle("Show In-Progress Events", isOn: $model.showCurrentEvents.animation(.spring(duration: 0.15)))
                        
                        Toggle("Show Upcoming Events", isOn: $model.showUpcomingEvents.animation(.spring(duration: 0.15)))
                        
                        if model.showCurrentEvents && model.showUpcomingEvents {
                            
                            
                            Picker("Prefer", selection: $model.multiTypeSelection) {
                                ForEach(MultiTypeEventDisplayPickerOptions.allCases, id: \.self) { type in
                                    switch type {
                                    case .currentFirst:
                                        Text("Current Events")
                                            .tag(MultiTypeEventDisplayPickerOptions.currentFirst)
                                    case .soonest:
                                        Text("Soonest to Start or End")
                                            .tag(MultiTypeEventDisplayPickerOptions.soonest)
                                    case .upcomingFirst:
                                        Text("Upcoming Events")
                                            .tag(MultiTypeEventDisplayPickerOptions.upcomingFirst)
                                    }
                                }
                            }

                            
                        }
                        
                    }
                    
                    Section("Display Options") {
                        
                        Toggle("Show Event Titles", isOn: $model.showTitles)
                        
                        
                        if settings.showTitles {
                            Slider(value: $model.titleLimit, in: 5...35, step: 1, label: {
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
                        
                        Toggle(isOn: $model.showIndicatorDot, label: {
                            Text("Show Calendar Indicator Dot")
                        })
                        
                        Toggle(isOn: .constant(true), label: {
                            Text("Show Completion Ring")
                        })
                        
                        Toggle(isOn: $model.showPercentageText, label: {
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
                
            }
            .formStyle(.grouped)
          
            
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
        self.showCountdowns = settings.showCountdowns
        
        self.showIndicatorDot = settings.showIndicatorDot
        
        self.showCurrentEvents = SingleEventFetchRule(rawValue: Int(settings.eventFetchRule)) != .upcomingOnly
        self.showUpcomingEvents = SingleEventFetchRule(rawValue: Int(settings.eventFetchRule)) != .inProgressOnly
        
        self.showPercentageText = settings.showPercentageText
        
    }
    

    
    var settings: StatusItemSettings
    
    var store: StatusItemStore
    
    @Published var showCurrentEvents: Bool {
        didSet {
            processEventRule()
        }
    }
    @Published var showUpcomingEvents: Bool {
        didSet {
            processEventRule()
        }
    }
    
    @Published var multiTypeSelection: StatusBarPane.MultiTypeEventDisplayPickerOptions = .soonest {
        didSet {
            processEventRule()
        }
    }
    
    @Published var showTitles: Bool {
        didSet {
            settings.showTitles = showTitles
            
            store.settingsStore.saveSettings(settings: settings)
            
        }
    }
    
    
    
    @Published var showCountdowns: Bool {
        didSet {
            settings.showCountdowns = showCountdowns
            
            store.settingsStore.saveSettings(settings: settings)
            
        }
    }
    
    @Published var titleLimit: Double {
        
        didSet {
            settings.titleLengthLimit = Double(Int(titleLimit))
            store.settingsStore.saveSettings(settings: settings)
            
        }
        
    }
    
    @Published var showIndicatorDot: Bool {
        didSet {
            settings.showIndicatorDot = showIndicatorDot
            
            store.settingsStore.saveSettings(settings: settings)
            
        }
    }
    
    
    @Published var showPercentageText: Bool {
        didSet {
            settings.showPercentageText = showPercentageText
            
            store.settingsStore.saveSettings(settings: settings)
            
        }
    }
    
    func processEventRule() {
        switch (showCurrentEvents, showUpcomingEvents) {
        case (true, false):
            settings.eventFetchRule = Int16(SingleEventFetchRule.inProgressOnly.rawValue)
        case (false, true):
            settings.eventFetchRule = Int16(SingleEventFetchRule.upcomingOnly.rawValue)
        case (false, false):
            settings.eventFetchRule = Int16(SingleEventFetchRule.noEvents.rawValue)
        case (true, true):
            switch multiTypeSelection {
            case .soonest:
                settings.eventFetchRule = Int16(SingleEventFetchRule.soonestCountdownDate.rawValue)
            case .currentFirst:
                settings.eventFetchRule = Int16(SingleEventFetchRule.preferInProgress.rawValue)
            case .upcomingFirst:
                settings.eventFetchRule = Int16(SingleEventFetchRule.preferUpcoming.rawValue)
            }
        }
        
        store.settingsStore.saveSettings(settings: settings)
        
    }

    
    
}

#Preview {
    
    let container = MacDefaultContainer()
    
    container.statusItemStore?.loadMainStatusItem()
    
    let settings = container.statusItemStore!.mainStatusItemContainer!.statusItemSettings!
    let store = container.statusItemStore!
    
    return StatusBarPane(model: StatusBarPaneModel(settings: settings, store: store))
        .environmentObject(container.statusItemStore!.mainStatusItemContainer!.info)
        .environmentObject(settings)
        .environmentObject(store)
}
