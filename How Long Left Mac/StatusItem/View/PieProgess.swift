//
//  PieProgess.swift
//  How Long Left Mac
//
//  Created by Ryan on 25/7/2024.
//

import SwiftUI

struct TestPieProgress: View {
    @State private var progress: Float = 0

    var body: some View {
        VStack(spacing:20) {
            HStack {
                Text("0%")
                Slider(value: $progress)
                Text("100%")
            }.padding()
            PieProgress(progress: $progress)
                .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                progress = 0.72
            }
        }
    }
}

struct PieProgress: View {
    @Binding var progress: Float

    var body: some View {
        GeometryReader { geometry in
            let minDimension = min(geometry.size.width, geometry.size.height)
            let strokeWidth = minDimension * 0.05 // Adjust stroke width relative to view size
            let paddingAmount = strokeWidth * 1.2 // Adjust padding relative to stroke width

            Circle()
                .stroke(Color.primary, lineWidth: strokeWidth)
                .overlay(
                    PieShape(progress: Double(progress))
                        .padding(paddingAmount)
                        .foregroundColor(.primary)
                )
                .frame(maxWidth: .infinity)
                .animation(Animation.linear, value: progress) // << here !!
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct PieShape: Shape {
    var progress: Double = 0.0

    var animatableData: Double {
        get {
            self.progress
        }
        set {
            self.progress = newValue
        }
    }

    private let startAngle: Double = (Double.pi) * 1.5
    private var endAngle: Double {
        self.startAngle + Double.pi * 2 * self.progress
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let arcCenter = CGPoint(x: rect.size.width / 2, y: rect.size.width / 2)
        let radius = rect.size.width / 2
        path.move(to: arcCenter)
        path.addArc(center: arcCenter, radius: radius, startAngle: Angle(radians: startAngle), endAngle: Angle(radians: endAngle), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct TestPieProgress_Previews: PreviewProvider {
    static var previews: some View {
        TestPieProgress()
    }
}
