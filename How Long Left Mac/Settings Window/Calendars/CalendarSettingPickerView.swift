//
//  CalendarSettingPickerView.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct CalendarSettingPickerView: View {
    @EnvironmentObject var manager: EventFilterDefaultsManager
    @ObservedObject var calendarInfo: CalendarInfo
    let toggleContext: String
    
    @State private var selection: Option = .full
    
    private enum Option: String, CaseIterable, Identifiable {
        case full = "Menu & Status Bar"
        case menuOnly = "Menu Only"
        case off = "Off"
        
        var id: String {
            return self.rawValue
        }
        
    }
    
    var body: some View {
        
        HStack {
           
            HStack {
                Circle()
                    .foregroundStyle(getColor())
                    .frame(width: 9)
                    
                    
                Text(calendarInfo.title!)
                    .lineLimit(1)
                Spacer()
            }
            
            Picker(selection: $selection, content: {
                
                ForEach(Option.allCases) {
                    Text($0.rawValue)
                        .tag($0)
                }
                
            }, label: {
                
               EmptyView()
                
            })
            .frame(width: 160)
            .pickerStyle(.menu)
            
        }
        
        .onChange(of: selection) {
            
            switch selection {
            case .full:
                manager.updateContexts(for: calendarInfo, addContextIDs: [HLLStandardCalendarContexts.app.rawValue, MacCalendarContexts.statusItem.rawValue])
            case .menuOnly:
                manager.updateContexts(for: calendarInfo, addContextIDs: [HLLStandardCalendarContexts.app.rawValue], removeContextIDs: [MacCalendarContexts.statusItem.rawValue])
            case .off:
                manager.updateContexts(for: calendarInfo, removeContextIDs: [MacCalendarContexts.statusItem.rawValue, HLLStandardCalendarContexts.app.rawValue])
            }
            
            ////print("Selection changed")
            
        }
        
        .onAppear() {
            
            let containsApp = manager.containsContext(calendarInfo: calendarInfo, contextID: HLLStandardCalendarContexts.app.rawValue)
            
            let containsStatusItem = manager.containsContext(calendarInfo: calendarInfo, contextID: MacCalendarContexts.statusItem.rawValue)
            
            if containsApp && containsStatusItem {
                selection = .full
            } else if containsApp {
                selection = .menuOnly
            } else {
                selection = .off
            }
            
        }
        
        
    
    }
    
    func getColor() -> Color {
        
        if let cal = manager.getEKCalendar(for: calendarInfo) {
            return Color(cal.cgColor)
        }
        
        return .gray
        
    }
   
}

