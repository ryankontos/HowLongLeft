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
    
    var percentageRingWidth: CGFloat = 0
    var percentageRingSize: CGFloat = 0
    
    var width: CGFloat {
        if showPercentage {
            return percentageRingWidth
        }
        
        return ringWidth
    }
    
    var size: CGFloat {
        if showPercentage {
            return percentageRingSize
        }
        
        return ringSize
    }
    
    var color: Color
    @State var showPercentage: Bool = true

    var body: some View {
        
        Button(action: {
            withAnimation {
                showPercentage.toggle()
            }
        }, label: {
            ZStack {
                Circle() // Background circle
                    .stroke(lineWidth: width)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)

                Circle() // Foreground circle showing progress
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
                    .foregroundColor(color.opacity(0.7))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
              
                    Text("\(Int(progress * 100))")
                        .font(.system(size: size / 2.5))
                        .fontWeight(.regular)
                        .foregroundColor(.secondary)
                        .opacity(showPercentage ? 1 : 0)
                
            }
            .contentShape(Rectangle())

        })
        .buttonStyle(PlainButtonStyle())
        
      
        .frame(width: size, height: size)
        .padding(width / 2)
        
        
    }
}

#Preview {
    ProgressRingView(progress: 0.5, ringWidth: 5, ringSize: 40, color: .blue)
        .frame(width: 250, height: 250)
}
