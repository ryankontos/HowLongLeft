//
//  Date.swift
//  How Long Left
//
//  Created by Ryan Kontos on 12/7/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation

extension Date {
    
    func getMondayOfWeek() -> Date {
        
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        comps.weekday = 2
        return cal.date(from: comps)!
        
    }
    
    func mondayOfWeekString() -> String {
       
        let mondayInWeek = getMondayOfWeek()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let firstDayString = dateFormatter.string(from: mondayInWeek)
        return "Week of \(firstDayString)"
    }
    
    func idString() -> String {
        
        return "\(self.formattedDate()), \(self.formattedTime())"
        
    }
    
    func userFriendlyRelativeString(at date: Date = Date()) -> String {
        
        let daysUntilDate = self.daysUntil(at: date)
        var dayText: String
        
        let dateFormatter  = DateFormatter()
        if self.year() == date.year() {
            
            dateFormatter.dateFormat = "d MMM"
            
        } else {
            
            dateFormatter.dateFormat = "d MMM YYYY"
            
        }
        
        let dateString = dateFormatter.string(from: self)
        
        if daysUntilDate < -1 {
            
           return dateString
            
        }
        
        switch daysUntilDate {
        case -1:
            dayText = "Yesterday"
        case 0:
            dayText = "Today"
        case 1:
            dayText = "Tomorrow"
        default:
            
            if daysUntilDate < 7 {
            
            let dateFormatter  = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            dayText = dateFormatter.string(from: self)
                
            } else {
                
                return dateString
                
            }
        }
        
        return dayText
        
    }
    
    var hasOccured: Bool {
        
        get {
            
            if self.timeIntervalSince(CurrentDateFetcher.currentDate) > -1 {
                return false
            } else {
                return true
            }
            
        }
        
    }
    
    func daysUntil(at date: Date = Date()) -> Int {
        
        let cal = Calendar.current
        
        return cal.numberOfDaysBetween(date, and: self)
        
    }
    
    func getDayOfWeekName(returnTodayIfToday: Bool) -> String {
        
        var returnText: String
        
        let dateFormatter  = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        returnText = dateFormatter.string(from: self)
        
        
        
        return returnText
        
    }
    
    func weekOfYear() -> Int {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        return calendar.components([.weekOfYear], from: self).weekOfYear!
        
        
    }
    
    func getRelativeString() -> String? {
        
        if self.daysUntil() == -1 {
            return "Yesterday"
        }
        
        if self.daysUntil() == 0 {
            return "Today"
        }
        
        if self.daysUntil() == 1 {
            return "Tomorrow"
        }
        
        return nil
        
    }
    
    
    private func is24Hour() -> Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!

        return dateFormat.firstIndex(of: "a") == nil
    }
    
    func formattedTime(seconds: Bool = false) -> String {
        
        let dateFormatter  = DateFormatter()
        
        if is24Hour() {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "h:mma"
        }
        
        if seconds {
            dateFormatter.dateFormat = "h:mm:ss"
        }
        
        return dateFormatter.string(from: self)
    }
    
    func formattedTimeTwelve() -> String {
        
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_AU")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
        let r = formatter.string(from: self)
             
        return r
    }
    
    func formattedDate() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: self)
        
    }
    
    func shortDate() -> String {
        
        if let string = getRelativeString() {
            return string
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)

    }
    
    func year() -> Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        return Int(dateFormatter.string(from: self))!
        
    }
    
    func startOfDay() -> Date {
        
        return Calendar.current.startOfDay(for: self)

        
    }
    
    func endOfDay() -> Date {
        
        return self.startOfDay().addingTimeInterval(86400)
        
    }
    
}
