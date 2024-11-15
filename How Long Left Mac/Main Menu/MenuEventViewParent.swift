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

    @ObservedObject var event: Event

    init(event: Event) {

        self.event = event

    }

    var body: some View {
        Group {

            if windowManager.isAttached {
                
                MenuEventView(event: event)
            } else {
                
                ScrollView {
                    
                    Spacer()
                    
                    Text("Detached")
                        
                
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }

        }
      
    }
}
