//
//  UserEventSource.swift
//  HowLongLeftKit
//
//  Created by Ryan on 21/5/2025.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
public class UserEventSource: ObservableObject {
    
    public var eventSummaryHash: String {
        let ids = customEvents.map { $0.eventIdentifier }
        return ids.joined(separator: ",").hashValue.description
    }
    
    private let container: NSPersistentContainer
    @Published public private(set) var customEvents: [HLLUserEvent] = []

    public init(container: NSPersistentContainer) {
        self.container = container
        fetchAll()
        // Listen for saves/edits via NotificationCenter if you like
    }

    public func fetchAll() {
        let req: NSFetchRequest<UserEventModel> = UserEventModel.fetchRequest()
        let mos = try! container.viewContext.fetch(req)
        self.customEvents = mos.compactMap {
            if let title = $0.title, let startDate = $0.startDate, let id = $0.id {
            
            // create swiftui color from hex using UIColor
                
                var color: Color = .red
                
                if let colorHex = $0.colorHex {
                    let hex = colorHex.trimmingCharacters(in: .whitespacesAndNewlines)
                    let scanner = Scanner(string: hex)
                    scanner.currentIndex = hex.startIndex
                    
                    var rgb: UInt64 = 0
                    if scanner.scanHexInt64(&rgb) {
                        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
                        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
                        let blue = CGFloat(rgb & 0xFF) / 255.0
                        color = Color(red: red, green: green, blue: blue)
                    }
                    
                    
                }
                
                
                
            return HLLUserEvent(title: title,
                        startDate: startDate,
                        endDate: $0.endDate ?? startDate,
                        isAllDay: false,
                                eventIdentifier: id.uuidString, color: color)
            } else {
                return nil
            }
           
        }
    }

    public func add(title: String, start: Date, end: Date, color: String = "#0000FF") {
        let mo = UserEventModel(context: container.viewContext)
        mo.id        = UUID()
        mo.title     = title
        mo.startDate = start
        mo.endDate   = end
        mo.colorHex  = color
        
        container.viewContext.insert(mo)
        
        try! container.viewContext.save()
        fetchAll()
    }

    public func delete(_ event: HLLUserEvent) {
        let req: NSFetchRequest<UserEventModel> = UserEventModel.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", UUID(uuidString: event.eventIdentifier)! as CVarArg)
        if let mo = try? container.viewContext.fetch(req).first {
            container.viewContext.delete(mo)
            try? container.viewContext.save()
            fetchAll()
        }
    }
}
