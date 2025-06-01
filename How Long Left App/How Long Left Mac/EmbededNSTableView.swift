//
//  EmbededNSTableView.swift
//  How Long Left Mac
//
//  Created by Ryan on 19/11/2024.
//

import SwiftUI
import AppKit

struct EmbeddedNSTableView: NSViewRepresentable {
    
    class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        let data: [String]
        
        init(data: [String]) {
            self.data = data
        }
        
        func numberOfRows(in tableView: NSTableView) -> Int {
            return data.count
        }
        
        func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
            return data[row]
        }
    }
    
    let sampleData: [String] = (1...1000).map { "This is medium-length text for row \($0) that demonstrates scrolling performance." }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(data: sampleData)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        
        let tableView = NSTableView()
        tableView.headerView = nil
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.backgroundColor = .clear
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Column"))
        column.title = "Sample Column"
        column.width = 400 // Adjust width for medium-length text
        tableView.addTableColumn(column)
        
        scrollView.documentView = tableView
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // Update view if needed
    }
}
