//
//  MenuEventView.swift
//  How Long Left Mac
//
//  Created by Ryan on 24/5/2024.
//

import SwiftUI
import HowLongLeftKit
import FluidMenuBarExtra

struct MenuEventView: View {
    
    @EnvironmentObject var calSource: CalendarSource
    var menuModel: WindowSelectionManager!
    var event: Event
    
    init(event: Event) {
        self.event = event
        self.menuModel = WindowSelectionManager(itemsProvider: self)
    }
    
    var body: some View {
        
        ZStack {
            
            VStack() {
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack {
                        
                          RoundedRectangle(cornerRadius: 10)
                            .frame(width: 4.5)
                            .foregroundColor(getColor())
                        
                        Text("\(event.title)")
                            .font(.system(size: 15.25, weight: .medium, design: .default))
                        
                        Spacer()
                        
                    }
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                    
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 50)
                        .foregroundStyle(.secondary.opacity(0.1))
                    
                    
                }
                
                Spacer()
                
              
                
                
            }
           
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .frame(width: 270, height: 350)
            
        }
           
    }
    
    func getColor() -> Color {
        
        if let cg = calSource.lookupCalendar(withID: event.calId)?.cgColor {
            return Color(cg)
        }
        
        return .blue
        
    }
    
}



extension MenuEventView: MenuSelectableItemsProvider {
    
    
    func getItems() -> [String] {
        return ["1","2"]
    }
    
    
}

#Preview {
    
    let container = MacDefaultContainer()
    
    return MenuEventView(event: .init(title: "[Maxim Street Health Hub] Reception", start: Date(), end: Date().addingTimeInterval(10)))
        .environmentObject(container.calendarReader)
        .environmentObject(ModernMenuBarExtraWindow(title: "Title", content: {
            AnyView(Text("Content"))
        }))
    
    
}
