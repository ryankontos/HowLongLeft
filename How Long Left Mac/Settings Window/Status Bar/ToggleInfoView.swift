//
//  ToggleInfoView.swift
//  How Long Left Mac
//
//  Created by Ryan on 10/8/2024.
//

import SwiftUI

struct ToggleInfoView: View {
    @Binding var isOn: Bool
    var labelText: String
    var filterButtonAction: () -> Void

    @State private var showPopover = false

    var body: some View {
        HStack {
            Text(labelText)
            Spacer()
            HStack {
                Toggle(isOn: $isOn.animation(.spring(duration: 0.5)), label: {
                    EmptyView()
                })
                .labelsHidden()
                .toggleStyle(.switch)

                Button(action: {
                    filterButtonAction()
                }, label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                })
                .buttonStyle(BorderlessButtonStyle())
                .disabled(!isOn)
             
            }
        }
    }
}

struct ToggleInfoView_Previews: PreviewProvider {
    @State static var toggleState = false

    static var previews: some View {
        ToggleInfoView(isOn: $toggleState, labelText: "Show In-Progress Events") {
            VStack {
                Text("Popover Content")
                Button("Close") {
                    // Action to close the popover can be handled here
                }
            }
            .padding()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
