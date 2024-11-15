//
//  CustomMenuCalendarPrefsContainerView.swift
//  How Long Left Mac
//
//  Created by Ryan on 24/6/2024.
//

import SwiftUI
import HowLongLeftKit

struct CustomMenuCalendarPrefsContainerView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        CalendarsPane(contexts: [HLLStandardCalendarContexts.app.rawValue])
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction, content: {
                    Button("Done", action: {
                        dismiss()
                    })

                })
            })

    }
}

#Preview {
    CustomMenuCalendarPrefsContainerView()
}
