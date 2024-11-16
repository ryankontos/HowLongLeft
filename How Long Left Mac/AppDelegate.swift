//
//  How_Long_Left_MacApp.swift
//  How Long Left Mac
//
//  Created by Ryan on 5/5/2024.
//

import Cocoa
import HowLongLeftKit
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItemStore: StatusItemStore?
    let container = MacDefaultContainer(id: "MacApp")
    var window: NSWindow!

    static var initTime = Date()

    func applicationDidFinishLaunching(_ notification: Notification) {
        
    }

    func applicationWillBecomeActive(_: Notification) {
            
        print("Will become active")
      
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        
    }

    func applicationWillTerminate(_: Notification) {
        
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        true
    }
}
