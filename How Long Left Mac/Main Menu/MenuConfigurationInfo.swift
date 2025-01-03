//
//  MenuConfigurationInfo.swift
//  How Long Left Mac
//
//  Created by Ryan on 25/6/2024.
//

import Foundation
import HowLongLeftKit
import SwiftUI

class MenuConfigurationInfo: ObservableObject {
    init(info: StatusItemConfiguration? = nil, settings _: StatusItemSettings?) {
        self.info = info
    }

    private var info: StatusItemConfiguration?
    private var settings: StatusItemSettings?

    func getColor() -> Color? {
        guard let info else { return nil }
        guard info.useCustomColor else { return nil }
        guard let code = info.customColorCode else { return nil }

        return Color(CGColor.fromHex(code)!)
    }

    func showTitles() -> Bool {
        guard let settings else { return false }
        return settings.showTitles
    }

    func getTitle() -> String? {
        if let info, info.isCustom {
            return info.title
        }

        return nil
    }
}
