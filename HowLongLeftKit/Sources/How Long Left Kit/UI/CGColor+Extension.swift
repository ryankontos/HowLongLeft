//
//  File.swift
//  
//
//  Created by Ryan on 26/6/2024.
//

import CoreGraphics


#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

public extension CGColor {
    // Convert CGColor to Hex String
    func toHex() -> String? {
        guard let components = self.components, components.count >= 3 else {
            return nil
        }

        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        let a = (components.count >= 4) ? Int(components[3] * 255) : 255

        if a < 255 {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }

    // Convert Hex String to CGColor
    static func fromHex(_ hex: String) -> CGColor? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }
        
        var rgba: UInt64 = 0
        let scanner = Scanner(string: hexString)
        scanner.scanHexInt64(&rgba)
        
        let r, g, b, a: CGFloat
        if hexString.count == 8 {
            r = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgba & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgba & 0x000000FF) / 255.0
        } else {
            r = CGFloat((rgba & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgba & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgba & 0x0000FF) / 255.0
            a = 1.0
        }
        
        return CGColor(red: r, green: g, blue: b, alpha: a)
    }
}


