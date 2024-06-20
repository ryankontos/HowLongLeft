//
//  MenuNoEventsView.swift
//  How Long Left Mac
//
//  Created by Ryan on 20/6/2024.
//

import SwiftUI

struct MenuNoEventsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No Events")
                .foregroundStyle(.secondary)
            Spacer()
            
        }
        .frame(height: 60)
    }
}

#Preview {
    MenuNoEventsView()
}
