//
//  File.swift
//  FluidMenuBarExtra
//
//  Created by Ryan on 19/11/2024.
//

import Foundation
import Cocoa

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    private var tableView: NSTableView!
    private var scrollView: NSScrollView!
    
    // Data source: 1000 rows with sample text
    private let data = (1...1000).map { "Row \($0)" }
    
    override func loadView() {
        // Create a root view
        self.view = NSView()
        
        // Force size for the view
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.setFrameSize(NSSize(width: 400, height: 300)) // Desired fixed size
        
        // Set up the scroll view
        scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        
        // Set up the table view
        tableView = NSTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add a single column to the table view
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Column"))
        column.title = "Sample Data"
        tableView.addTableColumn(column)
        
        // Embed the table view in the scroll view
        scrollView.documentView = tableView
        
        // Add scroll view to the main view
        view.addSubview(scrollView)
        
        // Set up constraints for the scroll view
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Fix the view size when displayed in a window
        if let window = view.window {
            window.setContentSize(NSSize(width: 400, height: 300))
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return data[row]
    }
    
    // MARK: - NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier("Cell")
        var cell = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
        
        if cell == nil {
            cell = NSTableCellView()
            cell?.identifier = identifier
            
            let textField = NSTextField()
            textField.isBezeled = false
            textField.drawsBackground = false
            textField.isEditable = false
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            cell?.addSubview(textField)
            cell?.textField = textField
            
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cell!.leadingAnchor, constant: 5),
                textField.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -5),
                textField.topAnchor.constraint(equalTo: cell!.topAnchor, constant: 2),
                textField.bottomAnchor.constraint(equalTo: cell!.bottomAnchor, constant: -2)
            ])
        }
        
        cell?.textField?.stringValue = data[row]
        return cell
    }
}
