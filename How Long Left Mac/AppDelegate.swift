//
//  How_Long_Left_MacApp.swift
//  How Long Left Mac
//
//  Created by Ryan on 5/5/2024.
//

import Cocoa
import SwiftUI
import HowLongLeftKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItemStore: StatusItemStore?
    var container: MacDefaultContainer!
    var window: NSWindow!

    static var initTime = Date()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
       // //print("Launched")
        // Initialize the status item store
      
        
        
        Task.detached { [self] in
            
            container = MacDefaultContainer()
            await container.setup()
            
        }

       
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        
        DispatchQueue.main.async {
           
           // NSApplication.shared.windows.forEach({ print("Window: \($0.description), \($0.isVisible)") })
            
            
            
            //print("Activating with \(windowsCount) visible windows")
            
        }
        
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
