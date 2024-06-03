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
    
    var mainMenuModel: MainMenuViewModel
    
    @State var displayEvent: Event?
    
    @Environment(\.scenePhase) var phase
    
    @EnvironmentObject var windowManager: FluidMenuBarExtraWindowManager
    
    @StateObject var menuEnv = MainMenuEnvironment()
    @State private var scrollPosition: CGPoint = .zero
    
    var body: some View {
        Group {
            main
                .transition(.opacity)
                .environmentObject(menuEnv)
        }
    }
    
    var main: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack {
                        let groups = mainMenuModel.eventGroups(at: Date())
                        ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                            if !group.events.isEmpty {
                                MenuEventListSection(title: group.title, events: group.events, mainMenuModel: mainMenuModel)
                            }
                            
                            if index < groups.endIndex-1 && groups.count > 1 {
                                Divider()
                            }
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                
                .onAppear() {
                
                    mainMenuModel.submenuManager = windowManager
                    windowManager.hoverManager = mainMenuModel
                    mainMenuModel.scrollProxy = proxy
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
                
                MenuButton(model: mainMenuModel, idForHover: OptionsSectionButton.settings.rawValue, content: {
                    HStack {
                        Text("Settings...")
                        Spacer()
                        Text("⌘ ,")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12, weight: .regular))
                    }
                }, action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        settingsWindow.open()
                    }
                })
                
                MenuButton(model: mainMenuModel, idForHover: OptionsSectionButton.quit.rawValue, content: {
                    HStack {
                        Text("Quit How Long Left")
                        Spacer()
                        Text("⌘ Q")
                            .foregroundStyle(.secondary)
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
        .background() {
            ArrowKeyDetector(
                onLeftArrow: { },
                onRightArrow: { },
                onUpArrow: {
                    mainMenuModel.selectPreviousItem()
                },
                onDownArrow: {
                    mainMenuModel.selectNextItem()
                }, onEnter: {
                    mainMenuModel.clickItem()
                }, onEsc: {
                    
                }
            )
        }
        .frame(minWidth: 300, maxWidth: 350, maxHeight: 400)
        .onChange(of: phase) { (old, new) in
            if new != .active {
               // mainMenuModel.selectedItemID = nil
            }
            
        }
    }
}

class MainMenuEnvironment: ObservableObject {
    @Published var displayEvent: Event?
}

