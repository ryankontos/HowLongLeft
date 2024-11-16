//
//  MenuTimelineView.swift
//  How Long Left Mac
//
//  Created by Ryan on 11/6/2024.
//

import SwiftUI

struct MenuTimelineView: View {
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(1...23, id: \.self) { index in
                        getSep(val: index)
                            .frame(height: proxy.size.width / 5)
                    }
                }
                .overlay {
                    VStack {
                        RoundedRectangle(cornerSize:
                                            /*@START_MENU_TOKEN@*/CGSize(width: 20, height: 10)/*@END_MENU_TOKEN@*/)
                            .padding(.horizontal, 70)
                            .frame(height: ((proxy.size.width / 5) * 2))
                            .offset(y: 8)

                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(width: 350, height: 400)
    }

    func getSep(val: Int) -> some View {
        VStack {
            HStack {
                Text("\(val) AM")
                    .frame(width: 40)

                RoundedRectangle(cornerRadius: 1)
                    .frame(height: 1)
            }

            Spacer()
        }

        .opacity(0.5)
        .foregroundStyle(.secondary)
        .background(Color.red)
    }
}

#Preview {
    MenuTimelineView()
}
