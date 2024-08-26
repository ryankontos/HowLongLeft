//
//  MainMenuContentView.swift
//  How Long Left Mac
//
//  Created by Ryan on 13/5/2024.
//

import SwiftUI
import HowLongLeftKit
import FluidMenuBarExtra

struct MainMenuContentView: View {
    
    @EnvironmentObject var pointStore: TimePointStore
    @EnvironmentObject var settingsWindow: SettingsWindow
    @EnvironmentObject var windowManager: FMBEWindowProxy
    @EnvironmentObject var calendarSource: CalendarSource
    
    var selectedManager: StoredEventManager
    
    @EnvironmentObject var eventListSettingsManager: EventListSettingsManager
    
    @EnvironmentObject var configInfo: MenuConfigurationInfo
    
    var selectionManager: WindowSelectionManager
    
    var model: MainMenuViewModel
    
    @State var displayEvent: Event?
    
    @Environment(\.scenePhase) var phase
    
    
    
    @StateObject var menuEnv = MainMenuEnvironment()
    @State private var scrollPosition: CGPoint = .zero
    
    
    var body: some View {
        Group {
            ZStack {
                ArrowKeySelectionManagingView(id: "Main", selectionManager: selectionManager)
                
                VStack {
                    
                   
                    
                    let groups = model.getEventGroups(at: Date())
                    
                    if !groups.isEmpty {
                        
                        if let title = configInfo.getTitle() {
                            
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    
                                    Text(title)
                                        .font(.system(size: 15, weight: .semibold))
                                        .padding(.vertical, 4)
                                    
                                    Divider()
                                    
                                }
                                
                                Spacer()
                                
                            }
                            
                            .padding(.horizontal, 10)
                            
                        }
                        
                        getEventGroupsView(groups: groups)
                            .transition(.opacity)
                            .environmentObject(menuEnv)
                    } else {
                        
                        if calendarSource.authorization == .denied {
                            MenuNoCalendarAccessView()
                            
                        } else {
                            
                            MenuNoEventsView()
                            
                        }
                        
                    }
                    
                    bottomView
                    
                }
               
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        
        .frame(minWidth: 300, maxWidth: 350, maxHeight: 450)
    }
    
    func getEventGroupsView(groups: [TitledEventGroup]) -> some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack {
                        
                        ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                            
                            MenuEventListSection(id: group.title ?? "nil", title: group.title, info: group.info, allDayEvents: [], events: group.events, forceProminence: group.flags.contains(.prominentSection), mainMenuModel: selectionManager, eventSelectionManager: selectedManager, timerContainer: GlobalTimerContainer())
                            
                            
                            if index < groups.endIndex-1 && groups.count > 1 {
                                Divider()
                            }
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                
                .onAppear() {
                
                    selectionManager.submenuManager = windowManager
                    windowManager.window?.hoverManager = selectionManager
                    selectionManager.scrollProxy = proxy
                }
            }
            
           
        }
        
      
    }
    
    var bottomView: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.horizontal, 10)
                .padding(.bottom, 4)
            
            MenuButton(model: selectionManager, idForHover: OptionsSectionButton.settings.rawValue, padding: 4, content: {
                HStack {
                    Text("Settings...")
                    Spacer()
                    Text("⌘ ,")
                        .foregroundColor(.secondary)
                        //.foregroundStyle(.secondary)
                        .font(.system(size: 12, weight: .regular))
                }
            }, action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    //settingsWindow.open()
                    windowManager.window?.resignKey()
                    settingsWindow.open()
                }
            })
            
            MenuButton(model: selectionManager, idForHover: OptionsSectionButton.quit.rawValue, padding: 4, content: {
                HStack {
                    Text("Quit How Long Left")
                    Spacer()
                    Text("⌘ Q")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12, weight: .regular))
                }
            }, action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    NSApp.terminate(nil)
                }
            })
        }
        
    }
    
  
    
}

class MainMenuEnvironment: ObservableObject {
    @Published var displayEvent: Event?
}


@MainActor
class MainMenuViewModel: MenuSelectableItemsProvider {
    
    
    
    var pointStore: TimePointStore
    
    var selectedManager: StoredEventManager
    
    var listSettings: EventListSettingsManager
    
    lazy var eventListProvider = EventListGroupProvider(settingsManager: listSettings)
    
    func getItems() -> [String] {
        let groups = getEventGroups(at: Date())
        return groups.flatMap { group in
            group.events.map { getEventId(eventId: $0.id, groupId: group.title ?? "nil") }
        } + OptionsSectionButton.allCases.map { $0.rawValue }
    }
    
    func getEventId(eventId: String, groupId: String) -> String {
        
        return "\(groupId)-(\(eventId)"
        
    }
    
    public func getEventGroups(at date: Date) -> [TitledEventGroup] {
        guard let currentPoint = pointStore.getPointAt(date: date) else { return [] }
        return eventListProvider.getGroups(from: currentPoint, selected: nil)
    }
    
    init(timePointStore: TimePointStore, listSettings: EventListSettingsManager, selectedManager: StoredEventManager) {
        
        self.pointStore = timePointStore
        self.listSettings = listSettings
        self.selectedManager = selectedManager
        
    }
    
}
