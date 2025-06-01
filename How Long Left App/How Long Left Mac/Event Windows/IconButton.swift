//
//  IconButton.swift
//  How Long Left Mac
//
//  Created by Ryan on 15/11/2024.
//

import SwiftUI

// Separate reusable IconButton view with custom hover effect
struct IconButton: View {
    var displayAsToggled: Bool
    let systemName: String
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17))
                .padding(.all, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isHovering ? Color.gray.opacity(0.4) : Color.gray.opacity(0.0))
                )
        }
        .buttonStyle(.borderless)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
