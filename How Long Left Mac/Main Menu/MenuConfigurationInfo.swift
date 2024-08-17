//
//  MenuConfigurationInfo.swift
//  How Long Left Mac
//
//  Created by Ryan on 25/6/2024.
//

import Foundation
import SwiftUI
import HowLongLeftKit
import Combine


class MenuConfigurationInfo: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var info: StatusItemConfiguration?
    private var settings: StatusItemSettings?
    private var defaultSettings: StatusItemSettings?
    
    init(info: StatusItemConfiguration? = nil, settings: StatusItemSettings?, defaultSettings: StatusItemSettings?) {
        self.info = info
        self.settings = settings
        self.defaultSettings = defaultSettings
        
        // Observe changes in `info` and trigger `objectWillChange`
        info?.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    var currentSettings: StatusItemSettings? {
        if info!.useDefaultSettings || !info!.isCustom {
            return defaultSettings
        } else {
            return settings
        }
    }
    
    func getColor() -> Color? {
        guard let info = info else { return nil }
        guard info.useCustomColor else { return nil }
        guard let code = info.customColorCode else { return nil }
        
        return Color(CGColor.fromHex(code)!)
    }
    
    func showTitles() -> Bool {
        guard let currentSettings = currentSettings else { return false }
        return currentSettings.showTitles
    }
    
    func showIndicators() -> Bool {
        guard let currentSettings = currentSettings else { return false }
        return currentSettings.showIndicatorDot
    }
    
    func showPercents() -> Bool {
        guard let currentSettings = currentSettings else { return false }
        return currentSettings.showPercentageText
    }
    
    func showCountdowns() -> Bool {
        guard let currentSettings = currentSettings else { return false }
        return currentSettings.showCountdowns
    }
    
    func getTitle() -> String? {
        if let info = info, info.isCustom {
            return info.title
        }
        return nil
    }
}
