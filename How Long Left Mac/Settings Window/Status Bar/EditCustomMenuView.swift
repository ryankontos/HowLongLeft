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
    
    @State var showCalendarSheet = false
    
    var isItemNew: Bool
    
    @State var item: CustomStatusItemContainer
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
            
            Section("Event Display") {
                
                
                HStack {
                    Label("Calendars", systemImage: "calendar")
                    Spacer()
                    Button(action: {
                        
                        showCalendarSheet = true
                        
                    }, label: {
                        Text("Manage")
                    })
                    
                }
                
                
               
                
                NavigationLink(destination: {
                    
                }, label: {
                    Label("Pinned Events", systemImage: "pin.fill")
                })
                
            }
            
            Section("Options") {
                
                Toggle("", isOn: .constant(true))
                
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
                        if self.isItemNew {
                            let context = store.customStatusItemStore.context
                            context.delete(item.info)
                            try? context.save()
                        }
                        
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                        let context = store.customStatusItemStore.context
                        context.insert(item.info)
                        try? context.save()
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
}

#Preview {
    
    let container = MacDefaultContainer()
    let manager = container.statusItemStore
    return NavigationStack {
        EditCustomMenuView(isItemNew: true, item: manager!.createNewCustomStatusItem())
    }
    .frame(width: 600, height: 500)
}
