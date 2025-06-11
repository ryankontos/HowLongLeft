//
//  NoEventsMessageProvider.swift
//  HowLongLeftKit
//
//  Created by Ryan on 10/6/2025.
//

import Foundation
import os // Import the os framework for unified logging

/**
 Provides randomly selected, localized messages for when no events are active.
 
 This class attempts to load messages from a JSON file corresponding to the user's current locale.
 If the localized file is missing or invalid, it gracefully falls back to English, and ultimately
 to a hardcoded default message.
 */
public final class NoEventsMessageProvider {
    
    // MARK: - Properties
    
    /// A static logger for consistent, categorized logging.
    /// Using a subsystem and category helps in filtering logs in the Console app.
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.ryankontos.HowLongLeftKit",
        category: "NoEventsMessageProvider"
    )
    
    /// The list of messages to display. It's a `let` because it's set only once at initialization.
    let messages: [String]

    /// A hardcoded default message to be used as a last resort.
    private static let defaultMessage = "Everything is quiet. For now."
    
    // MARK: - Initializer
    
    public init(locale: Locale = .current) {
        // 1. Try to load messages for the current locale.
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        let localizedFilename = "no_events_\(languageCode)"
        
        if let localizedMessages = Self.loadMessages(from: localizedFilename) {
            self.messages = localizedMessages
            Self.logger.info("Successfully loaded messages for language: '\(languageCode)'")
            return
        }
        
        // 2. If it fails, log a warning and fall back to English.
        Self.logger.warning("Could not load messages from '\(localizedFilename).json'. Falling back to English.")
        
        if let englishMessages = Self.loadMessages(from: "no_events_en") {
            self.messages = englishMessages
            return
        }
        
        // 3. If English also fails, log an error and use the hardcoded default.
        Self.logger.error("Failed to load English fallback messages. Using a hardcoded default.")
        self.messages = [Self.defaultMessage]
    }
    
    // MARK: - Private Helper
    
    /**
     Loads and decodes an array of strings from a specified JSON file in the main bundle.
     
     - Parameter filename: The name of the JSON file (without the .json extension).
     - Returns: An array of strings if successful, or `nil` if the file is not found, is empty, or fails to decode.
     */
    private static func loadMessages(from filename: String) -> [String]? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            // This is an expected failure if a language file doesn't exist, so debug level is appropriate.
            Self.logger.debug("Message file not found: '\(filename).json'")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedMessages = try JSONDecoder().decode([String].self, from: data)
            
            if decodedMessages.isEmpty {
                Self.logger.warning("Message file '\(filename).json' was found but is empty.")
                return nil
            }
            
            return decodedMessages
        } catch {
            // This is a more serious issue (e.g., malformed JSON) and warrants an error log.
            Self.logger.error("Failed to decode '\(filename).json': \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Public Method
    
    /// Returns a random message from the loaded list.
    public func getRandomMessage() -> String {
        // The initializer guarantees `messages` is never empty.
        // Using a default value here is an extra layer of safety.
        return messages.randomElement() ?? Self.defaultMessage
    }
}
