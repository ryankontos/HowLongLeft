//
//  MainAppCommuication.swift
//  How Long Left Mac Menu
//
//  Created by Ryan on 20/6/2024.
//

import Cocoa

class MainAppCommuication {
    
    static func launchMainApp() {
        if let url = URL(string: "howlongleftmac://") {
                    if NSWorkspace.shared.open(url) {
                        print("Successfully opened the app.")
                    } else {
                        print("Failed to open the app. The URL scheme may be incorrect or the app is not installed.")
                    }
                } else {
                    print("Invalid URL.")
                }
        }
    
}
