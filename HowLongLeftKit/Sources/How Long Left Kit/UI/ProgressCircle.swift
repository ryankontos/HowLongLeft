//
//  ProgressCircle.swift
//  HowLongLeftKit
//
//  Created by Ryan on 21/11/2024.
//

import SwiftUI

public struct ProgressCircle<Content: View>: View {
    // Customisation properties
    var progress: CGFloat
    var lineWidth: CGFloat
    var trackColor: Color
    var progressColor: Color
    var isRounded: Bool
    var progressType: ProgressType
    let content: Content

    // Enum for progress type
    public enum ProgressType {
        case fill // Progress increases the ring
        case deplete // Progress decreases the ring
    }

    // Initializer
    public init(progress: CGFloat,
                lineWidth: CGFloat = 10,
                trackColor: Color = Color.gray.opacity(0.3),
                progressColor: Color = .blue,
                isRounded: Bool = true,
                progressType: ProgressType = .fill,
                @ViewBuilder content: () -> Content) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.trackColor = trackColor
        self.progressColor = progressColor
        self.isRounded = isRounded
        self.progressType = progressType
        self.content = content()
    }

    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(trackColor, style: StrokeStyle(lineWidth: lineWidth))
            
            // Progress circle
            Circle()
                .trim(from: 0, to: adjustedProgress)
                .stroke(progressColor.gradient, style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: isRounded ? .round : .square
                ))
                .rotationEffect(.degrees(-90)) // Start at top
                .animation(.easeInOut, value: progress)
            // Animate changes
            
            // Center content
           
        }
       // .drawingGroup()
        .overlay {
            content
        }
    }

    private var adjustedProgress: CGFloat {
        switch progressType {
        case .fill:
            return progress
        case .deplete:
            return 1 - progress
        }
    }
}

// Preview for testing
struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // Fill progress
            ProgressCircle(progress: 0.75,
                           lineWidth: 15,
                           trackColor: .gray,
                           progressColor: .green,
                           isRounded: true,
                           progressType: .fill) {
                Text("75%")
                    .font(.title)
                    .bold()
            }
            .frame(width: 150, height: 150)
            
            // Deplete progress
            ProgressCircle(progress: 0.75,
                           lineWidth: 15,
                           trackColor: .gray,
                           progressColor: .red,
                           isRounded: true,
                           progressType: .deplete) {
                Text("25%")
                    .font(.title)
                    .bold()
            }
            .frame(width: 150, height: 150)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
