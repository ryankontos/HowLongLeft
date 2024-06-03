//
//  EventCardView.swift
//  How Long Left
//
//  Created by Ryan on 6/5/2024.
//

import SwiftUI

struct EventCardView: View {
    var eventName: String
    var endDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eventName)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            HStack {
                Text(countdownText(to: endDate))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)

                Spacer()

                ProgressView(value: progressValue(for: endDate))
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
    }

    private func countdownText(to date: Date) -> String {
        let current = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: current, to: date)
        let formatted = String(format: "%02d days %02d hours %02d mins",
                               components.day ?? 0, components.hour ?? 0, components.minute ?? 0)
        return formatted
    }

    private func progressValue(for date: Date) -> Double {
        let totalInterval = date.timeIntervalSince(Date())
        let total = Date().addingTimeInterval(totalInterval * 2).timeIntervalSince(Date())
        return 1 - (totalInterval / total)
    }
}

#Preview {
    EventCardView(eventName: "Sample Event", endDate: Date().addingTimeInterval(86400 * 5))
}
        
