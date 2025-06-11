//
//  NoCalendarAccessMessageProvider.swift
//  How Long Left Kit
//
//  Created by Ryan on 11/6/2025.
//

import Foundation

public struct NoCalendarAccessMessageProvider {
    
    private let messages = [
        "Nothing to see here. Literally. You turned off calendar access.",
        "Can’t read your future if you don’t let me look at it.",
        "Denied like your high school crush all over again.",
        "No calendar access, no countdowns. It’s that simple.",
        "Come back when you’re ready to share.",
        "I’m not a mind reader. I need permission.",
        "Locked out like it’s 3am and you forgot your keys.",
        "Trust issues? Because this feels personal.",
        "Your calendar’s in witness protection, apparently.",
        "This is why we can’t have nice things.",
        "You expect me to guess your schedule? Bold.",
        "Imagine denying access and still expecting features.",
        "I’d love to help, but you’ve tied my hands.",
        "Let me in and I’ll tell you when your next existential crisis is due.",
        "Until you allow access, this is just a pretty screen.",
        "Denied. Like my gym membership. (It’s fine.)",
        "Even spies have more access than I do right now.",
        "No calendar? No crying over missed meetings either.",
        "Can’t find any events. Might be because you’ve padlocked them.",
        "Want countdowns? I want permissions. Fair trade.",
        "No access = no context = no countdowns.",
        "I swear I won’t judge your calendar. Much.",
        "Your calendar is ghosting me.",
        "I’d check your schedule, but you’re gatekeeping it.",
        "Just a humble app, locked out of your busy life.",
        "Try turning it off and on again. Joking. Give me access.",
        "I could be helpful... if you let me be.",
        "This app does nothing now. Just vibes.",
        "Did Apple tell you I’m suspicious? Hurtful.",
        "Not much I can do until you say the magic word: 'Allow'."
    ]
    
    public init() {}
    
    public func getRandomMessage() -> String {
        messages.randomElement() ?? "Calendar access is disabled."
    }
}
