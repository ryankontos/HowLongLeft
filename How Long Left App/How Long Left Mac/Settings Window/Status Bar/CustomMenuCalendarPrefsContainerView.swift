//
//  CustomMenuCalendarPrefsContainerView.swift
//  How Long Left Mac
//
//  Created by Ryan on 24/6/2024.
//

import HowLongLeftKit
import SwiftUI

struct CustomMenuCalendarPrefsContainerView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        CalendarsPane(contexts: [HLLStandardCalendarContexts.app.rawValue])
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
    }
}

#Preview {
    CustomMenuCalendarPrefsContainerView()
}
