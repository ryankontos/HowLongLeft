//
//  SettingsRowView.swift
//  How Long Left
//
//  Created by Ryan on 31/5/2025.
//

import SwiftUI

import SwiftUI

struct SettingsRowView: View {
    let sfSymbolName: String
    let iconColour: Color
    let iconBackground: Color
    let title: String

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconBackground)
                    .frame(width: 40, height: 40)

                Image(systemName: sfSymbolName)
                    .foregroundColor(iconColour)
                    .font(.system(size: 20, weight: .semibold))
            }

            Text(title)
                .foregroundStyle(.primary)
                .font(.system(size: 19, weight: .semibold))

            Spacer()
        }
        .padding(.vertical, 2)
    }
}
#Preview {
    
    NavigationStack {
        
        List {
            Button(action: {}, label: {
                SettingsRowView(sfSymbolName: "gearshape.fill",
                                iconColour: .white,
                                        iconBackground: .blue,
                                        title: "Settings Example")
            })
            .buttonStyle(.plain)
        }
        
    }
    
   
}
