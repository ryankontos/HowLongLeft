//
//  CustomEventFormView.swift
//  HowLongLeft
//
//  Created by Ryan on 21/5/2025.
//

import SwiftUI
import UIKit

/// A SwiftUI form for creating a user-defined countdown,
/// with a swatch-based colour picker + optional custom colour.
struct CustomEventFormView: View {

    @Environment(\.dismiss) private var dismiss

    /// Called on Save with title, start/end, all-day flag & hex colour.
    let onSave: (_ title: String,
                 _ startDate: Date,
                 _ endDate: Date,
                 _ isAllDay: Bool,
                 _ colorHex: String) -> Void

    // MARK: - Form States

    @State private var title: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600)
    @State private var isAllDay: Bool = false

    @State private var selectedColor: Color = .blue
    @State private var useCustomColour: Bool = false

    private let defaultSwatches: [Color] = [
        .red, .orange, .yellow, .green,
        .blue, .purple, .pink, .gray
    ]

   

    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    Toggle("All day", isOn: $isAllDay)
                }

                Section("When") {
                    DatePicker("Starts",
                               selection: $startDate,
                               displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                    DatePicker("Ends",
                               selection: $endDate,
                               displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                }

                Section("Colour") {
                    // Swatch grid
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(defaultSwatches, id: \.self) { swatch in
                            Circle()
                                .fill(swatch)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedColor == swatch && !useCustomColour ? Color.primary : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                                .onTapGesture {
                                    selectedColor = swatch
                                    useCustomColour = false
                                }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.vertical, 8)

                    Toggle("Custom", isOn: $useCustomColour.animation())

                    if useCustomColour {
                        ColorPicker("Choose Color", selection: $selectedColor, supportsOpacity: false)
                    }

                  
                }
            }
            .navigationTitle("New Countdown")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
                              endDate >= startDate else { return }
                        onSave(title, startDate, endDate, isAllDay, "")
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || endDate < startDate)
                }
            }
        }
    }
}

// MARK: – Colour → Hex helpers




// MARK: – Preview

struct CustomEventFormView_Previews: PreviewProvider {
    static var previews: some View {
        CustomEventFormView { title, start, end, allday, hex in
            print("Saved:", title, start, end, allday, hex)
        }
    }
}
