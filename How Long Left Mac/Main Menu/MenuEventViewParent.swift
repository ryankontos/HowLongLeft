//
//  MenuEventViewParent.swift
//  How Long Left Mac
//
//  Created by Ryan on 17/6/2024.
//

import SwiftUI
import HowLongLeftKit
import FluidMenuBarExtra

struct MenuEventViewParent: View {
    
    @EnvironmentObject var menuEnv: MainMenuEnvironment
    @EnvironmentObject var calSource: CalendarSource
    @EnvironmentObject var windowManager: FMBEWindowProxy
    
    var menuModel: WindowSelectionManager!
    
    var event: Event
    
    init(event: Event) {
        
        self.event = event
        
        
    }
    
    var body: some View {
        Group {
            
            MenuEventView(event: event)
            
        }
        .onAppear() {
            windowManager.window?.hoverManager = menuModel
            menuModel.submenuManager = windowManager
        }
    }
}

