//
//  MenuNoCalendarAccessView.swift
//  How Long Left Mac
//
//  Created by Ryan on 20/6/2024.
//

import SwiftUI

struct MenuNoCalendarAccessView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {

            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .symbolRenderingMode(.palette)

                    .foregroundStyle(
                        .orange,
                        .white
                    )
                    .font(.system(size: 26))
                Text("How Long Left does not have access to your calendar.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

            }

        }

        .padding(.horizontal, 10)
        .padding(.vertical, 0)
        .frame(height: 60)
    }

    private var macOS14Avaliable: Bool {
            guard #available(macOS 14, *) else {
                return true
            }
            return false
        }

}

#Preview {
    MenuNoCalendarAccessView()
        .frame(width: 300)

}
