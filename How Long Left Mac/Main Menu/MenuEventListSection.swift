//
//  MenuEventListSection.swift
//  How Long Left Mac
//
//  Created by Ryan on 14/5/2024.
//

import SwiftUI
import HowLongLeftKit
import FluidMenuBarExtra

struct MenuEventListSection: View {
    
    var id: String
    
    var title: String?
    var allDayEvents: [Event]
    var events: [Event]
    var mainMenuModel: WindowSelectionManager
    
    @EnvironmentObject var env: MainMenuEnvironment
    @EnvironmentObject var reader: CalendarSource
    
    @EnvironmentObject var timerContainer: GlobalTimerContainer
    
    func getColor(for event: Event) -> Color? {
        
        guard event.isAllDay && event.status() == .upcoming else { return nil }
        
        if let cg = reader.lookupCalendar(withID: event.calId)?.cgColor {
            return Color(cg)
        }
        
        return nil
        
    }
    
    var body: some View {
        

        
        VStack(alignment: .leading, spacing: 0) {
            
            
            Section(content: {
                
                VStack {
                    
                    
                    ForEach(events) { event in
                        getMenuButton(for: event)
                    }
                    
                    
                    
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
    
    @ViewBuilder
    func getMenuButton(for event: Event) -> some View {
        
        MenuButton(model: mainMenuModel, idForHover: event.id, cornerRadius: event.isAllDay ? 12 : 5, customHighlight: getColor(for: event), fill: getColor(for: event) != nil, submenuContent: {
            AnyView(MenuEventView(event: event)
                .environmentObject(reader)
                .environmentObject(timerContainer)
            
            )
        }, content: {
            EventMenuListItem(event: event)
            
            
        }, action: {
            
        })
        .id(event.id)
        
    }
}

