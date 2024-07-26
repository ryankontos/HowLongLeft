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
    var info: String?
    var allDayEvents: [Event]
    var events: [Event]
    var mainMenuModel: WindowSelectionManager
    
    @ObservedObject var eventSelectionManager: StoredEventManager
    
    @EnvironmentObject var env: MainMenuEnvironment
    @EnvironmentObject var reader: CalendarSource
    @EnvironmentObject var eventInfoSource: StoredEventManager
    @EnvironmentObject var timerContainer: GlobalTimerContainer
    
    func getColor(for event: Event) -> Color? {
        
        guard event.isAllDay && event.status() == .upcoming else { return nil }
        
        if let cg = reader.lookupCalendar(withID: event.calendarID)?.cgColor {
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
                    
                    HStack {
                        
                        Text(title)
                            .fontWeight(.semibold)
                            .opacity(0.9)
                            
                        
                        
                        Spacer()
                        
                        
                        if let info {
                            
                            Text(info)
                            
                                .opacity(0.9)
                                .foregroundStyle(.secondary)
                            
                        }
                        
                    }
                    .padding(.bottom, 15)
                    .padding(.horizontal, 10)
                    
                   
                    
                    .frame(maxWidth: .infinity)
                    
                }
            })
            
            
        }
        .padding(.vertical, 7)
     
        
    }
    
    @ViewBuilder
    func getMenuButton(for event: Event) -> some View {
        
        MenuButton(model: mainMenuModel, idForHover: "\(self.id)-\(event.id)", cornerRadius: event.isAllDay ? 12 : 5, customHighlight: getColor(for: event), fill: getColor(for: event) != nil, submenuContent: {
            AnyView(MenuEventView(event: event)
                .environmentObject(eventInfoSource)
                .environmentObject(reader)
                .environmentObject(timerContainer)
            
            )
        }, content: {
            EventMenuListItem(event: event)
            
            
        }, action: {
            eventSelectionManager.addEventToStore(event: event, removeIfExists: true)
        })
        .id(event.id)
        
    }
}

