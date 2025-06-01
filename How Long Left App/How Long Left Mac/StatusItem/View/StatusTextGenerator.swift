//
//  StatusTextGenerator.swift
//  How Long Left Mac
//
//  Created by Ryan on 9/8/2024.
//

import Foundation
import HowLongLeftKit

class StatusTextGenerator {
    private let settings: StatusItemSettings

    init(settings: StatusItemSettings) {
        self.settings = settings
    }

    func getStatusItemText(for event: HLLEvent, at date: Date) -> String {
        let countdownText = createCountdownText(for: event, at: date)
        var statusText = event.status(at: date) == .upcoming ? "in \(countdownText)" : countdownText

        if settings.showTitles {
            statusText = "\(truncatedTitle(event.title)): \(statusText)"
        }

        return statusText
    }

    private func createCountdownText(for event: HLLEvent, at date: Date) -> String {
        let countdownDate = event.countdownDate(at: date)
        let percentDate = event.status(at: date) == .inProgress ? event.startDate : nil
        return countdown(endDate: countdownDate, percentageStartDate: percentDate, at: date, showSeconds: true)
    }

    private func countdown(endDate date: Date,
                           percentageStartDate: Date?,
                           at currentDate: Date,
                           showSeconds: Bool) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = showSeconds ? [.hour, .minute, .second] : [.hour, .minute]
        formatter.zeroFormattingBehavior = [.pad]

        guard date > currentDate else { return "00:00:00" }

        var timeString = formatter.string(from: currentDate, to: date) ?? "00:00:00"

        if settings.showPercentageText,
           let startDate = percentageStartDate,
           let percentageString = percentageCompletion(startDate: startDate, endDate: date, currentDate: currentDate) {
            timeString = "\(timeString) (\(percentageString))"
        }

        return timeString
    }

    private func percentageCompletion(startDate: Date, endDate: Date, currentDate: Date) -> String? {
        let totalTime = endDate.timeIntervalSince(startDate)
        let elapsedTime = currentDate.timeIntervalSince(startDate)

        guard totalTime > 0 else { return nil }

        let percentage = (elapsedTime / totalTime) * 100
        let roundedPercentage = Int(round(percentage))

        guard (0...100).contains(roundedPercentage) else { return nil }

        return "\(roundedPercentage)%"
    }

    private func truncatedTitle(_ fullText: String) -> String {
        let maxCharacters = Int(settings.titleLengthLimit)
        guard fullText.count > maxCharacters else { return fullText }

        let start = fullText.prefix(maxCharacters / 2)
        let end = fullText.suffix(maxCharacters / 2)
        return "\(start)...\(end)"
    }
}
