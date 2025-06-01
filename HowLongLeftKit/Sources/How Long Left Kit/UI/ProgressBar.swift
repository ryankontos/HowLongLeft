//
//  SwiftUIView.swift
//  HowLongLeftKit
//
//  Created by Ryan on 22/11/2024.
//

import SwiftUI

public struct ProgressBar: View {
    // Customisation properties
    var progress: CGFloat
    var lineWidth: CGFloat
    var trackColor: Color
    var progressColor: Color
    var isRounded: Bool
    
    // Initializer
    public init(progress: CGFloat,
                lineWidth: CGFloat = 10,
                trackColor: Color = Color.gray.opacity(0.3),
                progressColor: Color = .blue,
                isRounded: Bool = true) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.trackColor = trackColor
        self.progressColor = progressColor
        self.isRounded = isRounded
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: isRounded ? lineWidth / 2 : 0)
                    .fill(trackColor)
                    .frame(height: lineWidth)
                
                // Progress bar
                RoundedRectangle(cornerRadius: isRounded ? lineWidth / 2 : 0)
                    .fill(progressColor.gradient)
                    .frame(width: geometry.size.width * progress, height: lineWidth)
                    .animation(.easeInOut, value: progress) // Animate changes
            }
        }
    }
}

// Preview for testing
struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: 0.75,
                    lineWidth: 15,
                    trackColor: .gray,
                    progressColor: .green,
                    isRounded: true)
            .frame(width: 200) // Customise size
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
