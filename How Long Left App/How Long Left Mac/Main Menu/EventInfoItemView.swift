//
//  EventInfoItemView.swift
//  How Long Left Mac
//
//  Created by Ryan on 18/6/2024.
//

import SwiftUI

struct EventInfoItemView<Content: View>: View {
    var title: String
    var symbol: String
    var color: Color
    var infoView: () -> Content

    var body: some View {
        /*  HStack(alignment: .top, spacing: 10) {

         Image(systemName: symbol)
         .foregroundStyle(.secondary)
         .frame(width: 12)

         VStack {

         infoView()

         //.padding(.top, 1)

         }
         }
         // .background(Color.red)
         } */

        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)

            infoView()
        }
    }
}

#Preview {
    VStack {
        EventInfoItemView(title: "Location", symbol: "location.fill", color: .blue) {
            Text("3 Maxim Street, West Ryde, NSW, 2114")
        }
        .frame(width: 200)
    }

    .frame(width: 300, height: 300)
}
