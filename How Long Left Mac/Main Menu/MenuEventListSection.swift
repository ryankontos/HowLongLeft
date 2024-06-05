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
    var allDayEvents: [Event]
    var events: [Event]
    var mainMenuModel: WindowSelectionManager
    
    @EnvironmentObject var env: MainMenuEnvironment
    @EnvironmentObject var reader: CalendarSource
    
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
                    
                    MenuButton(model: mainMenuModel, idForHover: UUID().uuidString, padding: 5, submenuContent: {
                        
                        AnyView(ScrollView() {Text("Window")
                        }
                            .frame(width: 300, height: 200))
                        
                    }, content: {
                        Text("All Day Events...")
                            .foregroundStyle(.secondary)
                    }, action: {
                        
                    })
                    
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
        
        MenuButton(model: mainMenuModel, idForHover: event.id, customHighlight: getColor(for: event), fill: getColor(for: event) != nil, submenuContent: {
            AnyView(MenuEventView(event: event)
                .environmentObject(reader)
            
            )
        }, content: {
            EventMenuListItem(event: event)
            
            
        }, action: {
            
        })
        .id(event.id)
        
    }
}

