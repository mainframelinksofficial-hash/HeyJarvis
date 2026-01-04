//
//  BriefingManager.swift
//  HeyJarvisApp
//
//  Creates daily briefings combining multiple data sources
//
//  HOW IT WORKS:
//  1. User says "Good morning JARVIS" or "Daily briefing"
//  2. We fetch weather, calendar, and time
//  3. We combine them into a natural-sounding summary
//  4. JARVIS speaks the complete briefing
//

import Foundation

class BriefingManager: ObservableObject {
    static let shared = BriefingManager()
    
    private init() {}
    
    // MARK: - Daily Briefing
    
    /// Generate a complete daily briefing
    /// Combines time, weather, and calendar into one response
    func getDailyBriefing() async -> String {
        var parts: [String] = []
        
        // 1. Greeting based on time of day
        let greeting = getTimeBasedGreeting()
        parts.append(greeting)
        
        // 2. Current time
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: Date())
        parts.append("It's currently \(timeString).")
        
        // 3. Weather
        let weather = await WeatherManager.shared.getWeatherResponse()
        if !weather.contains("couldn't") && !weather.contains("unavailable") {
            parts.append(weather)
        }
        
        // 4. Calendar
        let granted = await EventManager.shared.requestAccess()
        if granted {
            let events = EventManager.shared.getTodaysEvents()
            parts.append(events)
        }
        
        // 5. Optional motivational closing
        parts.append(getMotivationalClosing())
        
        return parts.joined(separator: " ")
    }
    
    // MARK: - Helpers
    
    /// Get greeting based on current hour
    private func getTimeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good morning, sir."
        case 12..<17:
            return "Good afternoon, sir."
        case 17..<21:
            return "Good evening, sir."
        default:
            return "Good evening, sir. Burning the midnight oil, I see."
        }
    }
    
    /// Get a motivational closing phrase
    private func getMotivationalClosing() -> String {
        let closings = [
            "How may I assist you further?",
            "Ready to make today productive, sir.",
            "All systems are at your disposal.",
            "What shall we accomplish today?",
            "Standing by for your instructions."
        ]
        return closings.randomElement() ?? closings[0]
    }
    
    // MARK: - Quick Status
    
    /// Get a quick status update (shorter than full briefing)
    func getQuickStatus() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let dateString = dateFormatter.string(from: Date())
        
        return "It's \(timeString) on \(dateString). All systems nominal, sir."
    }
}
