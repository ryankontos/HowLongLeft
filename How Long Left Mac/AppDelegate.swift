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
    let container = MacDefaultContainer()
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
       // //print("Launched")
        // Initialize the status item store
        
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }
        
        
    
       
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
