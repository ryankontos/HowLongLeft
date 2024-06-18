//
//  ProgressRingView.swift
//  How Long Left Mac
//
//  Created by Ryan on 18/6/2024.
//

import SwiftUI

struct ProgressRingView: View {
    var progress: Double // Progress should be a value between 0 and 1
    var ringWidth: CGFloat
    var ringSize: CGFloat
    var color: Color
    var showPercentage: Bool = true

    var body: some View {
        ZStack {
            Circle() // Background circle
                .stroke(lineWidth: ringWidth)
                .opacity(0.3)
                .foregroundColor(Color.gray)

            Circle() // Foreground circle showing progress
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(color.opacity(0.7))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            if showPercentage {
                Text("\(Int(progress * 100))")
                    .font(.system(size: ringSize / 2.5))
                    .fontWeight(.regular)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: ringSize, height: ringSize)
        .padding(ringWidth / 2) // Add padding to account for the stroke width
    }
}
