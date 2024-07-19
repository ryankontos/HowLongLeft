//
//  StatusItemContentView.swift
//  How Long Left Mac
//
//  Created by Ryan on 11/5/2024.
//

import SwiftUI
import HowLongLeftKit

struct StatusItemContentView: View {
    
   
    
    @Environment(\.self) var environment
    
    @EnvironmentObject var pointStore: TimePointStore
    @EnvironmentObject var menuConfiguration: MenuConfigurationInfo
    
    
    var body: some View {
        
        TimelineView(.periodic(from:StatusItemContentView.previousSecondWithMillisecondZero, by: 1)) { context in
            
            Group {
                
                if let event = getEvent(at: context.date) {
                    
                    
                        
                        Text("\(getStatusItemText(event: event, at: context.date))")
                            .lineLimit(1)
                            .monospacedDigit()
                        
                       
                        
                    
                        
                } else {
                    Image(systemName: "clock")
                        .renderingMode(.template)
                       
                        
                }
                
            }
            .foregroundColor(menuConfiguration.getColor())
            
        }
        .fixedSize(horizontal: true, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        
        
    
       
    }
    
    func getEvent(at date: Date) -> Event? {
        
        guard let point = pointStore.getPointAt(date: date) else {
            //print("Status item countdown got no current timepoint for \(date)")
            return nil
        }
        
       // print("Status item countdown got current timepoint!")
        return point.fetchSingleEvent(accordingTo: .preferInProgress)
        
    }
    
    func getStatusItemText(event: Event, at: Date) -> String {
        
        
        var countdown =  "\(countdown(to: event.countdownDate(at: at), from: at, showSeconds: true))"
        
        if menuConfiguration.showTitles() {
            countdown = "\(event.title): \(countdown)"
        }
        
        return countdown
    }
    
     
    func countdown(to date: Date, from: Date, showSeconds: Bool) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        
        // Set the allowed units
        if showSeconds {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.hour, .minute]
        }
        
        // Show leading zeroes
        formatter.zeroFormattingBehavior = [.pad]
        
        
        // Ensure the target date is in the future
        guard date > from else {
            return "00:00:00"
        }
        
        let result = formatter.string(from: from, to: date)!
        //print(result)
        return result
    }

    static var previousSecondWithMillisecondZero: Date = {
            // Get the current date
            let currentDate = Date()

            // Get the current calendar
            let calendar = Calendar.current

            // Subtract one second from the current date
            guard let previousSecondDate = calendar.date(byAdding: .second, value: -1, to: currentDate) else {
                fatalError("Failed to subtract one second from the current date.")
            }

            // Get the components of the previous second date
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: previousSecondDate)
            // Set the millisecond to zero
            components.nanosecond = 0

            // Create the new date with the millisecond set to zero
            guard let dateWithMillisecondZero = calendar.date(from: components) else {
                fatalError("Failed to create the date with millisecond set to zero.")
            }

            return dateWithMillisecondZero
        }()
}

#Preview {
    StatusItemContentView()
}

