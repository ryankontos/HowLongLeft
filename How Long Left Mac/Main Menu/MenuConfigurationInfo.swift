//
//  MenuConfigurationInfo.swift
//  How Long Left Mac
//
//  Created by Ryan on 25/6/2024.
//

import Foundation
import SwiftUI
import HowLongLeftKit


class MenuConfigurationInfo: ObservableObject {
    
    init(info: CustomStatusItemInfo? = nil) {
        self.info = info
    }
    
    private var info: CustomStatusItemInfo?
    
    func getColor() -> Color? {
        
        
        guard let info else { print("Color returning nil"); return nil }
        guard info.useCustomColor else { print("Color returning nil"); return nil }
        guard let code = info.customColorCode else { print("Color returning nil"); return nil }
        
        return Color(CGColor.fromHex(code)!)
    }
    
    func getTitle() -> String? {
        
        if let info {
            return info.title
        }
        
        return nil
    }
    
}
