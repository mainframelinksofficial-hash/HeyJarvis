//
//  BriefingManager.swift
//  HeyJarvisApp
//
//  Creates daily briefings combining multiple data sources
//  with personality-aware narration.
//

import Foundation
import UIKit

class BriefingManager: ObservableObject {
    static let shared = BriefingManager()
    
    private init() {}
    
    // MARK: - Daily Briefing
    
    /// Generate a complete, personality-aware daily briefing
    func getDailyBriefing() async -> String {
        let personality = SettingsManager.shared.selectedPersonality
        var parts: [String] = []
        
        // 1. Greeting & Personality Intro
        parts.append(getTimeBasedGreeting(for: personality))
        
        // 2. Memory Recall (Personal Touch)
        if let randomMemory = MemoryManager.shared.getRandomMemory() {
            switch personality {
            case .professional:
                parts.append("I recall you mentioned: \(randomMemory).")
            case .sarcastic:
                parts.append("Don't forget: \(randomMemory). I'm keeping track, obviously.")
            case .friendly:
                parts.append("Just a quick reminder: \(randomMemory)!")
            }
        }
        
        // 3. Time Check
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: Date())
        parts.append("It's currently \(timeString).")
        
        // 4. Battery Status
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        if batteryLevel > 0 {
            if batteryLevel < 20 {
                parts.append("Critical alert: Battery is low at \(batteryLevel)%. Charge required.")
            } else {
                parts.append("System power is at \(batteryLevel)%.")
            }
        }
        
        // 5. Weather
        let weather = await WeatherManager.shared.getWeatherResponse()
        if !weather.contains("couldn't") && !weather.contains("unavailable") {
            parts.append(weather)
        }
        
        // 6. Calendar
        if await EventManager.shared.requestAccess() {
            let events = EventManager.shared.getTodaysEvents()
            parts.append(events)
        }
        
        // 7. Reminders (New)
        // Access is requested in previous step theoretically, but safe to call
        let reminders = await EventManager.shared.getIncompleteReminders()
        if !reminders.isEmpty {
            parts.append(reminders)
        }
        
        // 8. Closing
        parts.append(getMotivationalClosing(for: personality))
        
        return parts.joined(separator: " ")
    }
    
    // MARK: - Helpers
    
    private func getTimeBasedGreeting(for personality: JarvisPersonality) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        
        switch hour {
        case 5..<12: timeOfDay = "Morning"
        case 12..<17: timeOfDay = "Afternoon"
        case 17..<21: timeOfDay = "Evening"
        default: timeOfDay = "Night"
        }
        
        switch personality {
        case .professional:
            return "Good \(timeOfDay.lowercased()), sir."
        case .sarcastic:
            if timeOfDay == "Morning" { return "Oh, look who's awake. Good morning." }
            return "Good \(timeOfDay.lowercased()). Still here, I see."
        case .friendly:
            return "Good \(timeOfDay.lowercased())! Hope you're feeling great!"
        }
    }
    
    private func getMotivationalClosing(for personality: JarvisPersonality) -> String {
        switch personality {
        case .professional:
            return [
                "All systems nominal. Ready for your command.",
                "How may I assist you further?",
                "Standing by for instructions."
            ].randomElement()!
        case .sarcastic:
            return [
                "Try not to mess it up today.",
                "I'll be here. Waiting. As always.",
                "Let's get this over with."
            ].randomElement()!
        case .friendly:
            return [
                "Let's make today key!",
                "You've got this!",
                "Ready to help whenever you need me!"
            ].randomElement()!
        }
    }
    
    // MARK: - Quick Status
    
    func getQuickStatus() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: Date())
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        let battery = Int(UIDevice.current.batteryLevel * 100)
        
        return "Time: \(timeString). Battery: \(battery)%. Systems Online."
    }
}
