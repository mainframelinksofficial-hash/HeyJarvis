//
//  CommandManager.swift
//  HeyJarvisApp
//
//  Parses voice commands and extracts intent
//

import Foundation

class CommandManager {
    
    private let commandPatterns: [(keywords: [String], type: CommandType)] = [
        // Photo commands
        (["take a photo", "take photo", "capture photo", "take a picture", "take picture", "snap a photo", "photograph"], .takePhoto),
        
        // Video commands
        (["show video", "play video", "show last video", "play last video", "show my video", "play my video", "recent video"], .showVideo),
        
        // Note commands
        (["record note", "take a note", "record a note", "make a note", "save a note", "voice memo", "record memo"], .recordNote),
        
        // Time commands
        (["what time", "tell me the time", "current time", "time is it", "what's the time"], .getTime),
        
        // Date commands
        (["what date", "what day", "today's date", "current date", "what is today"], .getDate),
        
        // Weather commands
        (["weather", "forecast", "temperature", "how hot", "how cold", "is it raining"], .getWeather),
        
        // Brightness commands
        (["brightness", "screen brightness", "display brightness", "brighter", "dimmer"], .setBrightness),
        
        // Volume commands
        (["volume", "louder", "quieter", "turn up", "turn down", "mute", "unmute"], .setVolume),
        
        // Music commands
        (["play music", "play some music", "start music", "play a song", "play my music", "pause music", "stop music", "skip song", "next song", "spotify", "open spotify"], .playMusic),
        
        // Message commands
        (["send message", "text message", "send a text", "message to"], .sendMessage),
        
        // Reminder commands
        (["set reminder", "remind me", "set an alarm", "create reminder", "don't let me forget"], .setReminder),
        
        // Timer commands
        (["set timer", "set a timer", "timer for", "start timer", "countdown", "count down"], .setTimer),
        
        // Calendar commands
        (["calendar", "schedule", "events", "what am i doing", "what's next", "appointments"], .calendar),
        
        // Home commands
        (["lights", "turn on", "turn off", "homekit", "smart home", "scene", "illuminate", "activate"], .homeControl),
        
        // Daily Briefing commands
        (["good morning", "daily briefing", "morning briefing", "what's new", "catch me up", "status report"], .dailyBriefing),
    ]
    
    func parseCommand(_ text: String) -> CommandType {
        let lowercased = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        for pattern in commandPatterns {
            for keyword in pattern.keywords {
                if lowercased.contains(keyword) {
                    return pattern.type
                }
            }
        }
        
        // If no specific command matched, it's a general AI query
        return .unknown
    }
    
    func extractParameter(from text: String, for type: CommandType) -> String? {
        let lowercased = text.lowercased()
        
        switch type {
        case .setReminder:
            // Try to extract what to remind about
            if let range = lowercased.range(of: "remind me to ") {
                return String(text[range.upperBound...])
            }
            if let range = lowercased.range(of: "remind me about ") {
                return String(text[range.upperBound...])
            }
        case .sendMessage:
            // Try to extract message content
            if let range = lowercased.range(of: "message saying ") {
                return String(text[range.upperBound...])
            }
        default:
            return nil
        }
        
        return nil
    }
}
