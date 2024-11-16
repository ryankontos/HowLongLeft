//
//  Card_EventPickerView.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/11/2024.
//

import HowLongLeftKit
import SwiftUI

struct Card_EventPickerView: View {
    var event: Event

    var action: () -> Void

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 3)
                .foregroundStyle(event.color)
                .frame(width: 4)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading) {
                Text(event.title)

                if event.status() == .inProgress {
                    Text("Ends \(event.endDate.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Starts \(event.endDate.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("Select") {
                action()
            }
        }
    }
}

#Preview {
    Card_EventPickerView(event: .example) {
    }
}
