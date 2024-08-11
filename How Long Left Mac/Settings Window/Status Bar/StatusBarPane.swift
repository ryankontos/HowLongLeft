//
//  StatusBarPane.swift
//  How Long Left Mac
//
//  Created by Ryan on 22/6/2024.
//

import SwiftUI
import HowLongLeftKit

struct StatusBarPane: View {
    
    @EnvironmentObject var store: StatusItemStore
    @EnvironmentObject var config: StatusItemConfiguration
    @EnvironmentObject var settings: StatusItemSettings
    @EnvironmentObject var statusItemContainer: StatusItemContainer
    
    @ObservedObject var model: StatusBarPaneModel
    
    
    var body: some View {
        NavigationStack {
            Form {
                StatusBarPaneContent(model: model)
                    .environmentObject(statusItemContainer.filtering!)
                    .navigationTitle("Status Bar")
            }
            .formStyle(.grouped)
            
        }
       
    }
}

#Preview {
    let container = MacDefaultContainer()
    container.statusItemStore?.loadMainStatusItem()
    
    let settings = container.statusItemStore!.mainStatusItemContainer!.statusItemSettings
    let store = container.statusItemStore!
    
    return StatusBarPane(model: StatusBarPaneModel(settings: settings, store: store))
        .environmentObject(container.statusItemStore!.mainStatusItemContainer!.info)
        .environmentObject(settings)
        .environmentObject(store)
        .environmentObject(container.statusItemStore!.mainStatusItemContainer!)
}
