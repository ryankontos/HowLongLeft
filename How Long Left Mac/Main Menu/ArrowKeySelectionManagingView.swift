//
//  ArrowKeySelectionManagingView.swift
//  How Long Left Mac
//
//  Created by Ryan on 6/6/2024.
//

import FluidMenuBarExtra
import SwiftUI

struct ArrowKeySelectionManagingView: View {
    var selectionManager: WindowSelectionManager

    var iden: String

    @Environment(\.scenePhase) var phase

    init(id: String, selectionManager: WindowSelectionManager) {
        self.iden = id
        self.selectionManager = selectionManager
    }

    var body: some View {
        ArrowKeyDetector(id: iden, onLeftArrow: {
        }, onRightArrow: {
        }, onUpArrow: {
            selectionManager.selectPreviousItem()
        }, onDownArrow: {
            selectionManager.selectNextItem()
        }, onEnter: {
            selectionManager.clickItem()
        }, onEsc: {
        })
    }
}
