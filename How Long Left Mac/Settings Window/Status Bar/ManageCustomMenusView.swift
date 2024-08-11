//
//  ManageCustomMenusView.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/6/2024.
//

import SwiftUI
import HowLongLeftKit

struct ManageCustomMenusView: View {
    
    @EnvironmentObject var store: StatusItemStore
    
    @State var editingItem: StatusItemContainer?
    
    @State var editingNewItem = false
    
    @State var showEditor = false
    
    var body: some View {
        
        let items = Array(store.customStatusItemContainers)
        
        if items.isEmpty {
            
            VStack {
                
                Text("You have no custom menus.")
                Button("Create", action: {
                    editingNewItem = true
                    editingItem = store.createNewCustomStatusItem()
                })
                
            }
            
        } else {
            
            Form {
                
                
                
                
                
                ForEach(items) { item in
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            
                            Text("\(item.info.title ?? "No Title")")
                            Text("\(item.getCalendarsDescription())")
                            
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            editingNewItem = false
                            editingItem = item
                        }
                        
                        Button("Delete", role: .destructive) {
                            
                            store.statusItemDataStore.removeCustomStatusItem(item: item.info)
                            
                        }
                        
                    }
                    
                }
                
                
                
                
            }
            .formStyle(.grouped)
            .toolbar {
                Button("New", systemImage: "plus") {
                    editingNewItem = true
                    editingItem = store.createNewCustomStatusItem()
                }
            }
            .navigationTitle("Custom Menus")
            .sheet(item: $editingItem, onDismiss: {
                
                store.loadCustomStatusItemContainers()
                
            }) { item in
                NavigationStack {
                    EditCustomMenuView(isItemNew: self.editingNewItem, item: item)
                        .environmentObject(store)
                        .environmentObject(item)
                        .environmentObject(item.config!)
                        .environmentObject(item.filtering!)
                        .environmentObject(item.statusItemSettings)
                        .frame(width: 500, height: 500)
                }
            }
            .onDisappear() {
                editingItem = nil
            }
            
        }
        
    }
}

#Preview {
    ManageCustomMenusView()
        
}
