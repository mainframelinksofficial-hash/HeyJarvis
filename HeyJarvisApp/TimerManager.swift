//
//  TimerManager.swift
//  HeyJarvisApp
//
//  Manages timers with local notifications
//
//  HOW IT WORKS:
//  1. User says "Set a timer for 5 minutes"
//  2. We parse the time from the text
//  3. We schedule a local notification
//  4. iOS delivers the notification even if app is closed!
//

import Foundation
import UserNotifications

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    
    @Published var activeTimers: [ActiveTimer] = []
    
    private init() {
        requestNotificationPermission()
    }
    
    // MARK: - Permission
    
    /// Request permission to show notifications
    /// This is called once when the app starts
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Timer Creation
    
    /// Set a timer for the given duration
    /// - Parameter text: The user's command (e.g., "5 minutes", "30 seconds")
    /// - Returns: A response string for JARVIS to speak
    func setTimer(from text: String) -> String {
        // Parse the time from the text
        guard let seconds = parseTime(from: text) else {
            return "I couldn't understand the timer duration, sir. Please specify like '5 minutes' or '30 seconds'."
        }
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "JARVIS Timer"
        content.body = "Your timer is complete, sir."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        // Create the trigger (fires after 'seconds' seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        
        // Create a unique identifier for this timer
        let identifier = "jarvis_timer_\(Date().timeIntervalSince1970)"
        
        // Create and schedule the request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling timer: \(error)")
            }
        }
        
        // Track the timer
        let timer = ActiveTimer(id: identifier, duration: seconds, startTime: Date())
        activeTimers.append(timer)
        
        // Format the response
        let formattedTime = formatDuration(seconds)
        return "Timer set for \(formattedTime), sir. I'll notify you when it's complete."
    }
    
    // MARK: - Time Parsing
    
    /// Parse time duration from text like "5 minutes" or "30 seconds"
    private func parseTime(from text: String) -> TimeInterval? {
        let lowercased = text.lowercased()
        
        // Regular expression to find numbers followed by time units
        let patterns: [(String, TimeInterval)] = [
            ("(\\d+)\\s*hour", 3600),
            ("(\\d+)\\s*minute", 60),
            ("(\\d+)\\s*second", 1),
            ("(\\d+)\\s*min", 60),
            ("(\\d+)\\s*sec", 1),
            ("(\\d+)\\s*hr", 3600)
        ]
        
        var totalSeconds: TimeInterval = 0
        var foundAny = false
        
        for (pattern, multiplier) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                if let match = regex.firstMatch(in: lowercased, options: [], range: range) {
                    if let numberRange = Range(match.range(at: 1), in: lowercased) {
                        if let number = Double(lowercased[numberRange]) {
                            totalSeconds += number * multiplier
                            foundAny = true
                        }
                    }
                }
            }
        }
        
        return foundAny ? totalSeconds : nil
    }
    
    /// Format seconds into human-readable string
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        var parts: [String] = []
        if hours > 0 { parts.append("\(hours) hour\(hours == 1 ? "" : "s")") }
        if minutes > 0 { parts.append("\(minutes) minute\(minutes == 1 ? "" : "s")") }
        if secs > 0 && hours == 0 { parts.append("\(secs) second\(secs == 1 ? "" : "s")") }
        
        return parts.joined(separator: " and ")
    }
    
    // MARK: - Cancel Timers
    
    func cancelAllTimers() {
        for timer in activeTimers {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timer.id])
        }
        activeTimers.removeAll()
    }
}

// MARK: - Timer Model

struct ActiveTimer: Identifiable {
    let id: String
    let duration: TimeInterval
    let startTime: Date
    
    var endTime: Date {
        return startTime.addingTimeInterval(duration)
    }
    
    var remainingTime: TimeInterval {
        return max(0, endTime.timeIntervalSinceNow)
    }
}
