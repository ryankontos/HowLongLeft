//
//  EditCustomMenuView.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/6/2024.
//

import SwiftUI
import AppKit
import HowLongLeftKit

struct EditCustomMenuView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var store: StatusItemStore
    @EnvironmentObject var settings: StatusItemSettings
    @EnvironmentObject var config: StatusItemConfiguration
    
    @State var showCalendarSheet = false
    
    var isItemNew: Bool
    
    @ObservedObject var model: Model
    
    @State var item: StatusItemContainer
    @State var field1: String = ""
    
    @State var useCustomColor = false
    
    @State var color = Color.white
    
    var body: some View {
        
        Form {
            
            Section("Custom Status Item") {
                
                TextField("Name", text: Binding(
                    get: { return self.field1 },
                    set: { self.field1 = $0 }
                ), onCommit: {
                    DispatchQueue.main.async {
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    }
                })
                
                
                
            }
            
            Section {
                
                Toggle("Use Custom Color", isOn: $useCustomColor.animation())
                
                if useCustomColor {
                    
                    ColorPicker("Color", selection: $color)
                    
                }
                
            }
            
            Section {
                
                
                HStack {
                    Label("Calendars", systemImage: "calendar")
                    Spacer()
                    Button(action: {
                        
                        showCalendarSheet = true
                        
                    }, label: {
                        Text("Manage")
                    })
                    
                }
                
            }
            
            Section("Status Item") {
                
            
                Toggle(isOn: $model.mirrorMainStatusItemSettings.animation(), label: {
                    Text("Mirror Main Status Item")
                })
                
                    
                
            }
            
            if !config.useDefaultSettings {
                
                Section {
                    
                    StatusBarPaneContent(model: StatusBarPaneModel(settings: settings, store: store))
                    
                }
                
            }
            
           
        }
        .onAppear() {
            
            guard let title = item.info.title, !title.isEmpty else { return }
            self.field1 = title
            
            self.useCustomColor = item.info.useCustomColor
            
            if let code = item.info.customColorCode {
                self.color = Color(CGColor.fromHex(code)!)
            }
            
        }
        .toolbar {
            Group {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            
                            if self.isItemNew {
                                store.statusItemDataStore.removeCustomStatusItem(item: item.info)
                               
                            }
                            
                            
                        })
                        
                       
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                        store.statusItemDataStore.saveItem(item: item.info)
                        dismiss()
                    }
                    .disabled(!titleValid)
                }
            }
        }
      

            
        
        .formStyle(.grouped)
        .sheet(isPresented: $showCalendarSheet, content: {
            CustomMenuCalendarPrefsContainerView()
                .frame(width: 500, height: 500)
                .environmentObject(item.filtering!)
                 
        })
        //.presentedWindowToolbarStyle(.expanded)
        
    }
    
    var titleValid: Bool {
       
        if field1.isEmpty { return false }
        return true
    }
    
    func save() {
        
        self.item.info.title = self.field1
        self.item.info.useCustomColor = self.useCustomColor
        self.item.info.customColorCode = color.cgColor?.toHex()
        
        
        self.item.info.activated = true
        self.item.checkActivation()
       
        
    }
    
    @MainActor
    class Model: ObservableObject {
        
        var store: StatusItemStore
        var config: StatusItemConfiguration
        
        init(store: StatusItemStore, config: StatusItemConfiguration) {
            self.store = store
            self.config = config
            self.mirrorMainStatusItemSettings = config.useDefaultSettings
        }
        
        @Published var mirrorMainStatusItemSettings: Bool {
            didSet {
                
                config.useDefaultSettings = mirrorMainStatusItemSettings
                
                DispatchQueue.main.async {
                    
                    self.store.resetCustomStatusItems()
                    
                }
            }
        }
        
    }
}

#Preview {
    
    let container = MacDefaultContainer()
    let manager = container.statusItemStore
    
    let item = manager!.createNewCustomStatusItem()
    
    return NavigationStack {
        EditCustomMenuView(isItemNew: true, model: .init(store: container.statusItemStore!, config: item.config!), item: item)
    }
    .frame(width: 600, height: 500)
}
