//
//  CardView.swift
//  How Long Left
//
//  Created by Ryan on 3/10/2024.
//

import SwiftUI

struct CardView: View {
    let title: String
    let subtitle: String
    let timeRemaining: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))

            HStack(spacing: 10) {

                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 5)
                    .foregroundStyle(color)
                    .opacity(0.7)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .opacity(0.8)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(timeRemaining)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .opacity(0.7)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color(uiColor: .tertiarySystemFill))
                    }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 15)
        }
        .padding(.horizontal, 20)

    }
}
