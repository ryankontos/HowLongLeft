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
    
    @EnvironmentObject var menuEnv: MainMenuEnvironment
    
    @EnvironmentObject var calSource: CalendarSource
    
    @EnvironmentObject var windowManager: ModernMenuBarExtraWindow
    
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
        
        ZStack {
            
            //ArrowKeySelectionManagingView(id: "Second \(event.title)", selectionManager: menuModel)
            
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
                
                MenuButton(model: menuModel, idForHover: "1", submenuContent: {
                    
                    AnyView (
                        
                        VStack{
                            
                            Text("1")
                            
                        }
                            .frame(width: 200, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        
                    )
                    
                },content: {
                    
                    Text("Button 1")
                    
                }, action: {
                    
                })
                
                MenuButton(model: menuModel, idForHover: "2", submenuContent: {
                    
                    AnyView (
                        
                        VStack{
                            
                            Text("2")
                            
                        }
                            .frame(width: 200, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        
                    )
                    
                },content: {
                    
                    Text("Button 2")
                    
                }, action: {
                    
                })
                
            }
            .onAppear() {
                windowManager.hoverManager = menuModel
                menuModel.submenuManager = windowManager
            }
            .padding(.all, 20)
            .frame(width: 250, height: 200)
            
        }
           
    }
}



extension MenuEventView: MenuSelectableItemsProvider {
    
    
    func getItems() -> [String] {
        return ["1","2"]
    }
    
    
}
