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
    @EnvironmentObject var windowManager: ModernMenuBarExtraWindow
    
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
                main
                    .transition(.opacity)
                    .environmentObject(menuEnv)
            }
        }
    }
    
    var main: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack {
                        let groups = model.getEventGroups(at: Date())
                        ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                            if !group.events.isEmpty {
                                MenuEventListSection(id: group.title!, title: group.title, allDayEvents: [], events: group.events, mainMenuModel: selectionManager)
                            }
                            
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
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
        .padding(.horizontal, 6)
        .padding(.vertical, 9)
        
        .frame(minWidth: 300, maxWidth: 350, maxHeight: 400)
      
    }
    
    
    
  
    
}

class MainMenuEnvironment: ObservableObject {
    @Published var displayEvent: Event?
}


class MainMenuViewModel: MenuSelectableItemsProvider {
    
    var pointStore: TimePointStore
    
    func getItems() -> [String] {
        let groups = getEventGroups(at: Date())
        return groups.flatMap { $0.events.map { $0.id } } + OptionsSectionButton.allCases.map { $0.rawValue }
    }
    
    public func getEventGroups(at date: Date) -> [TitledEventGroup] {
        guard let currentPoint = pointStore.getPointAt(date: date) else { return [] }
        
        var groups = [
            TitledEventGroup("On Now", currentPoint.inProgressEvents),
        ]
        
        let upcomingGroups = currentPoint.upcomingGroupedByStartDay.map {
            TitledEventGroup("\($0.date.formatted(date: .abbreviated, time: .omitted))", $0.events)
        }
        
        groups.append(contentsOf: upcomingGroups)
        
        return groups
    }
    
    init(timePointStore: TimePointStore) {
        
        self.pointStore = timePointStore
        
    }
    
}
