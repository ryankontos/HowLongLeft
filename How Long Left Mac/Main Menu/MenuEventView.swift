//
//  MenuEventView.swift
//  How Long Left Mac
//
//  Created by Ryan on 24/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct MenuEventView: View {
    
    @EnvironmentObject var menuEnv: MainMenuEnvironment
    
    @EnvironmentObject var calSource: CalendarSource
    
    var menuModel: WindowSelectionManager!
    
    init(event: Event) {
       
        self.event = event
        
        self.menuModel = WindowSelectionManager(itemsProvider: self)
    }
    
    var event: Event
    
    func getColor() -> Color {
        
        if let cg = calSource.lookupCalendar(withID: event.calId)?.cgColor {
            return Color(cg)
        }
        
        return .white
        
    }
    
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Circle()
                    .frame(width: 9)
                    .foregroundColor(getColor())
                
                Text("\(event.title)")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                
                Spacer()
                
            }
            
            Spacer()
            
        }
        .padding(.all, 20)
        .frame(width: 250, height: 200)
        
       
           
    }
}



extension MenuEventView: MenuSelectableItemsProvider {
    
    
    func getItems() -> [String] {
        return []
    }
    
    
}
