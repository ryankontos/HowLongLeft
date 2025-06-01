//
//  FluidMenuBarExtra.swift
//  FluidMenuBarExtra
//
//  Created by Lukas Romsicki on 2022-12-17.
//  Copyright © 2022 Lukas Romsicki.
//

import SwiftUI

/// A class you use to create a SwiftUI menu bar extra in both SwiftUI and non-SwiftUI
/// applications.
///
/// A fluid menu bar extra is configured by initializing it once during the lifecycle of your
/// app, most commonly in your application delegate. In SwiftUI apps, use
/// `NSApplicationDelegateAdaptor` to create an application delegate in which
/// a ``FluidMenuBarExtra`` can be created:
///
/// ```swift
/// class AppDelegate: NSObject, NSApplicationDelegate {
///     private var menuBarExtra: FluidMenuBarExtra?
///
///     func applicationDidFinishLaunching(_ notification: Notification) {
///         menuBarExtra = FluidMenuBarExtra(title: "My Menu", systemImage: "cloud.fill") {
///             Text("My SwiftUI View")
///         }
///     }
/// }
/// ```
///
/// Because an application delegate is a plain object, not a `View` or `Scene`, you
/// can't pass state properties to views in the closure of `FluidMenuBarExtra` directly.
/// Instead, define state properties inside child views, or pass published properties from
/// your application delegate to the child views using the `environmentObject`
/// modifier.
///
///
///
///
///

/*

public final class FluidMenuBarExtra {
    public let statusItem: FluidMenuBarExtraWindowManager

    public init(title: String, @ViewBuilder content: @escaping () -> AnyView) {
       
        statusItem = FluidMenuBarExtraWindowManager(title: title, content: content)
    }

    public init(title: String, image: String, @ViewBuilder content: @escaping () -> AnyView) {
        
        statusItem = FluidMenuBarExtraWindowManager(title: title, image: image, content: content)
    }

    public init(title: String, systemImage: String, @ViewBuilder content: @escaping () -> AnyView) {
       
        statusItem = FluidMenuBarExtraWindowManager(title: title, systemImage: systemImage, content: content)
    }
    
    public func setMonospacedFont() {
        statusItem.setMonospacedFont()
    }
    
    public func setTitle(_ newTitle: String?) {
        statusItem.setTitle(newTitle: newTitle)
    }
    
    public func setImage(imageName: String) {
        statusItem.setImage(imageName: imageName)
    }
    
    public func setImage(systemImageName: String, accessibilityDescription: String? = nil) {
        statusItem.setImage(systemImageName: systemImageName, accessibilityDescription: accessibilityDescription)
    }
    
    public func destroy() {
        statusItem.destroy()
    }
    
}
 */
