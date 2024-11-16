//
//  EditCustomMenuView.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/6/2024.
//

import AppKit
import HowLongLeftKit
import SwiftUI

public struct EditCustomMenuView: View {
    
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var store: StatusItemStore
    @EnvironmentObject var settings: StatusItemSettings
    @EnvironmentObject var config: StatusItemConfiguration

    @State private var showCalendarSheet = false

    public var isItemNew: Bool

    @State public var item: StatusItemContainer
    @State private var field1: String = ""

    @State private var useCustomColor = false

    @State private var color = Color.white

    public var body: some View {
        Form {
            Section("Custom Status Item") {
                TextField("Name", text: Binding(
                    get: { field1 },
                    set: { field1 = $0 }
                )) {
                    DispatchQueue.main.async {
                        print("Resigning first responder")
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    }
                }
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
                Toggle(isOn: .constant(true)) {
                    Text("Mirror Main Status Item")
                }
            }

            if !config.useDefaultSettings {
                Section {
                    StatusBarPaneContent(model: StatusBarPaneModel(settings: settings, store: store))
                }
            }
        }
        .onAppear {
            guard let title = item.info.title, !title.isEmpty else { return }
            field1 = title

            useCustomColor = item.info.useCustomColor

            if let code = item.info.customColorCode {
                color = Color(CGColor.fromHex(code)!)
            }
        }
        .toolbar {
            Group {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if isItemNew {
                            store.statusItemDataStore.removeCustomStatusItem(item: item.info)
                        }

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
        .sheet(isPresented: $showCalendarSheet) {
            CustomMenuCalendarPrefsContainerView()
                .frame(width: 500, height: 500)
                .environmentObject(item.filtering!)
        }
        // .presentedWindowToolbarStyle(.expanded)

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
/*
#Preview {
    let container = MacDefaultContainer(id: "MacPreview")
    let manager = container.statusItemStore
    NavigationStack {
        EditCustomMenuView(isItemNew: true, item: manager!.createNewCustomStatusItem())
    }
    .frame(width: 600, height: 500)
}
*/
