//
//  AppDelegate.swift
//  How Long Left Mac Menu
//
//  Created by Ryan on 20/6/2024.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    let container = MacDefaultContainer()
    
    lazy var prefs = SettingsWindow(container: container)

    override init() {
        
        super.init()
        
        registerApp()
        
        prefs.open()
        
        /*DistributedNotificationCenter.default().addObserver(
                    self,
                    selector: #selector(handleNotification(_:)),
                    name: NSNotification.Name("howlongleftmac.OpenSettingsWindow"),
                    object: nil
                )*/
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        
        terminateApp(bundleIdentifier: "ryankontos.How-Long-Left-Mac-Menu")
        //launchHelperApp()
        
        
        
    }
    
    
    
    @objc func handleNotification(_ notification: Notification) {
        prefs.open()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


    func registerApp() {
            // Get the URL of the app's bundle
            if let bundleURL = Bundle.main.bundleURL as CFURL? {
                // Register the app with Launch Services
                let status = LSRegisterURL(bundleURL, true)
                if status == noErr {
                    print("App registered successfully with Launch Services.")
                } else {
                    print("Failed to register app: \(status)")
                }
            } else {
                print("Failed to get bundle URL.")
            }
        }

    func launchHelperApp() {
        // Get the path to the embedded helper app
        guard let helperAppPath = Bundle.main.path(forResource: "How Long Left Mac Menu", ofType: "app") else {
            print("Helper app not found in the resources folder.")
            return
        }
        
        // Create a Process to launch the helper app using the 'open' command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [helperAppPath]
        
        do {
            try process.run()
            //process.waitUntilExit()
            print("Helper app launched successfully.")
        } catch {
            print("Failed to launch helper app: \(error.localizedDescription)")
        }
    }

    
    func application(_ application: NSApplication, open urls: [URL]) {
            for url in urls {
                handleURL(url)
            }
    }

        private func handleURL(_ url: URL) {
            // Add your custom URL handling logic here
            if let scheme = url.scheme, scheme == "myapp" {
                // Example: Extract and print the path component
                let path = url.path
                print("Received URL with path: \(path)")
                // Handle other components or queries if necessary
            }
        }


}

