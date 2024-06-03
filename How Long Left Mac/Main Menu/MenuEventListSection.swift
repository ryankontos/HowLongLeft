//
//  MenuEventListSection.swift
//  How Long Left Mac
//
//  Created by Ryan on 14/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct MenuEventListSection: View {
    
    var title: String?
    var events: [Event]
    var mainMenuModel: MainMenuViewModel
    
    @EnvironmentObject var env: MainMenuEnvironment
    @EnvironmentObject var reader: CalendarSource
    
    var body: some View {
        

        
        VStack(alignment: .leading, spacing: 0) {
            Section(content: {
                ForEach(events) { event in
                    
                    MenuButton(model: mainMenuModel, idForHover: event.id, submenuContent: {
                        AnyView(MenuEventView(event: event)
                            .environmentObject(reader)
                        
                        )
                    }, content: {
                        MenuInProgressListItemView(event: event)
                        
                        
                    }, action: {
                        
                    })
                    .id(event.id)
                    
                
                   
                    
                    
                   
                }
            }, header: {
                if let title {
                    
                    PushLeading {
                        Text(title)
                            .fontWeight(.semibold)
                            .opacity(0.9)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 10)
                        
                    }
                    
                    .frame(maxWidth: .infinity)
                    
                }
            })
            
            
        }
        
    }
}

