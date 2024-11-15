//
//  How_Long_Left_MacApp.swift
//  How Long Left Mac
//
//  Created by Ryan on 5/5/2024.
//

import Cocoa
import SwiftUI
import HowLongLeftKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItemStore: StatusItemStore?
    let container = MacDefaultContainer(id: "MacApp")
    var window: NSWindow!

    static var initTime = Date()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
       // //print("Launched")
        // Initialize the status item store

    }

    func applicationWillBecomeActive(_ notification: Notification) {

        DispatchQueue.main.async {

           // NSApplication.shared.windows.forEach({ print("Window: \($0.description), \($0.isVisible)") })

            // print("Activating with \(windowsCount) visible windows")

        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
