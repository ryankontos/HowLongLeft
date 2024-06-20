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
    //@EnvironmentObject var settingsWindow: SettingsWindow
    @EnvironmentObject var windowManager: ModernMenuBarExtraWindow
    @EnvironmentObject var calendarSource: CalendarSource
    
    @EnvironmentObject var eventListSettingsManager: EventListSettingsManager
    
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
                        
                        getEventGroupsView(groups: groups)
                            .transition(.opacity)
                            .environmentObject(menuEnv)
                    } else {
                        
                        if calendarSource.authorization != .denied {
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
        .padding(.vertical, 9)
        
        .frame(minWidth: 300, maxWidth: 310, maxHeight: 400)
    }
    
    func getEventGroupsView(groups: [TitledEventGroup]) -> some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack {
                        
                        ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                            
                                MenuEventListSection(id: group.title!, title: group.title, allDayEvents: [], events: group.events, mainMenuModel: selectionManager)
                            
                            
                            if index < groups.endIndex-1 && groups.count > 1 {
                                Divider()
                            }
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                
                .onAppear() {
                
                    selectionManager.submenuManager = windowManager
                    windowManager.hoverManager = selectionManager
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
                    windowManager.resignKey()
                    MainAppCommuication.launchMainApp()
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


class MainMenuViewModel: MenuSelectableItemsProvider {
    
    
    
    var pointStore: TimePointStore
    
    var listSettings: EventListSettingsManager
    
    lazy var eventListProvider = EventListGroupProvider(settingsManager: listSettings)
    
    func getItems() -> [String] {
        let groups = getEventGroups(at: Date())
        return groups.flatMap { $0.events.map { $0.id } } + OptionsSectionButton.allCases.map { $0.rawValue }
    }
    
    public func getEventGroups(at date: Date) -> [TitledEventGroup] {
        guard let currentPoint = pointStore.getPointAt(date: date) else { return [] }
        return eventListProvider.getGroups(from: currentPoint)
    }
    
    init(timePointStore: TimePointStore, listSettings: EventListSettingsManager) {
        
        self.pointStore = timePointStore
        self.listSettings = listSettings
        
    }
    
}
