//
//  CircularCountdownView.swift
//  How Long Left Mac
//
//  Created by Ryan on 14/11/2024.
//

import SwiftUI

struct CircularCountdownView: View {
    // MARK: - Properties
    var eventName: String
    var color: Color
    var targetDate: Date

    @EnvironmentObject var eventWindow: EventWindow
    
    @State var showSettings = false
    
    private let lineWidth: CGFloat = 13
    
    @State private var timeRemaining: TimeInterval = 0
    @State private var countdownComplete = false

    // MARK: - Timer
    private var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateRemainingTime()
        }
    }

    // MARK: - Body
    var body: some View {
        VStack {
           Spacer()
            countdownView
           Spacer()
        }
        
        .cornerRadius(20)
        .shadow(radius: 10)
        .onAppear(perform: startTimer)
        .frame(minWidth: 150, maxWidth: .infinity, minHeight: 150, maxHeight: .infinity)
        .background(controlButtons)
        .animation(.easeInOut, value: countdownComplete)
        .sheet(isPresented: $showSettings) {
           
            EventWindowSettingsView(isPresented: $showSettings)
        }
        .onChange(of: showSettings, { _, new in
            
            var time = 0.0
            
            if new == false {
                time = 0.1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                
                eventWindow.toggleMaxSizeLock(enabled: new)
            }
            
        })
    
    }
    
    // MARK: - Views
    private var countdownView: some View {
        ZStack {
            if countdownComplete {
                completionView
            } else {
                progressCircle
                    .background(timerTextView)
                    .padding(.top, 25)
                    .frame(maxWidth: 250, maxHeight: 250)
            }
        }
       
        .padding(.all, 20)
    }

    private var completionView: some View {
        
        VStack(spacing: 15) {
            
            ZStack {
                Circle()
                    .fill(color)
                    .transition(.scale)
                    .animation(.easeInOut, value: countdownComplete)
                    .frame(width: 70, height: 70)
                Image(systemName: "checkmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .transition(.scale)
                    .symbolEffect(.scale, options: .default, isActive: true)
                
            }
            
            Text("Event Complete")
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .font(.title2)
                
        }
    }
    
    private var progressCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    color.gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
    }
    
    private var timerTextView: some View {
        VStack {
            Text(formattedTime)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal, 5)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            Text("Time Left")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.all, 15)
    }

    private var controlButtons: some View {
        VStack {
            Spacer()
            HStack {
                IconButton(displayAsToggled: eventWindow.floating, systemName: eventWindow.floating ? "square.stack.3d.down.forward.fill" : "square.stack.3d.down.forward") {
                    eventWindow.floating.toggle()
                }
                .help("Keep on Top")
                
                Spacer()
                IconButton(displayAsToggled: false, systemName: "gearshape") {
                   showSettings = true
                }
                .help("Settings")
            }
           
            .padding(.horizontal, 7)
            .padding(.bottom, 10)
        }
        //.background(.red)
    }

    // MARK: - Computed Properties
    private var progress: Double {
        max(0, timeRemaining / countdownDuration)
    }

    private var countdownDuration: TimeInterval {
        max(0, targetDate.timeIntervalSinceNow)
    }

    private var formattedTime: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Functions
    private func updateRemainingTime() {
        timeRemaining = countdownDuration
        if timeRemaining <= 0 {
            withAnimation {
                countdownComplete = true
            }
        }
    }

    private func startTimer() {
        _ = timer
        updateRemainingTime()
    }
}

// MARK: - Preview
struct CircularCountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CircularCountdownView(
            eventName: "Sample Event",
            color: .blue,
            targetDate: Date().addingTimeInterval(3)
        )
    }
}
