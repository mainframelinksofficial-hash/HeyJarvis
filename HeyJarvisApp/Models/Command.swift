//
//  Command.swift
//  HeyJarvisApp
//
//  Data models for commands and app state
//

import Foundation
import SwiftUI

// MARK: - Command Type
enum CommandType: String, CaseIterable {
    case takePhoto = "photo"
    case showVideo = "video"
    case recordNote = "note"
    case getTime = "time"
    case getDate = "date"
    case getWeather = "weather"
    case setBrightness = "brightness"
    case setVolume = "volume"
    case playMusic = "music"
    case sendMessage = "message"
    case setReminder = "reminder"
    case setTimer = "timer"
    case calendar = "calendar"
    case homeControl = "home"
    case dailyBriefing = "briefing"
    case fitness = "fitness"
    case openApp = "app"
    case openApp = "app"
    case navigate = "navigate"
    case remember = "remember"
    case executeProtocol = "protocol"
    case unknown = "unknown"
    
    var icon: String {
        switch self {
        case .takePhoto: return "camera.fill"
        case .showVideo: return "play.rectangle.fill"
        case .recordNote: return "mic.fill"
        case .getTime: return "clock.fill"
        case .getDate: return "calendar"
        case .getWeather: return "cloud.sun.fill"
        case .setBrightness: return "sun.max.fill"
        case .setVolume: return "speaker.wave.3.fill"
        case .playMusic: return "music.note"
        case .sendMessage: return "message.fill"
        case .setReminder: return "bell.fill"
        case .setTimer: return "timer"
        case .calendar: return "calendar"
        case .homeControl: return "lightbulb.fill"
        case .dailyBriefing: return "sun.horizon.fill"
        case .fitness: return "figure.run"
        case .openApp: return "app.badge"
        case .navigate: return "location.fill"
        case .remember: return "brain.head.profile"
        case .executeProtocol: return "bolt.shield.fill"
        case .unknown: return "brain.head.profile"
        }
    }
    
    var displayName: String {
        switch self {
        case .takePhoto: return "Photo"
        case .showVideo: return "Video"
        case .recordNote: return "Note"
        case .getTime: return "Time"
        case .getDate: return "Date"
        case .getWeather: return "Weather"
        case .setBrightness: return "Brightness"
        case .setVolume: return "Volume"
        case .playMusic: return "Music"
        case .sendMessage: return "Message"
        case .setReminder: return "Reminder"
        case .setTimer: return "Timer"
        case .calendar: return "Calendar"
        case .homeControl: return "Home"
        case .dailyBriefing: return "Briefing"
        case .fitness: return "Fitness"
        case .openApp: return "App"
        case .navigate: return "Navigate"
        case .remember: return "Memory"
        case .executeProtocol: return "Protocol"
        case .unknown: return "AI Chat"
        }
    }
    
    var responseText: String {
        switch self {
        case .takePhoto: return "Photo captured and saved to your library, sir."
        case .showVideo: return "Playing your most recent video now, sir."
        case .recordNote: return "Note recorded successfully, sir."
        case .getTime: return "" // Handled dynamically
        case .getDate: return "" // Handled dynamically
        case .getWeather: return "" // Handled dynamically
        case .setBrightness: return "Adjusting display brightness now, sir."
        case .setVolume: return "Volume adjusted as requested, sir."
        case .playMusic: return "Playing music for you now, sir."
        case .sendMessage: return "I'll need your device's permission to send messages, sir."
        case .setReminder: return "Reminder set, sir. I'll notify you at the appropriate time."
        case .setTimer: return "Timer started, sir. I'll alert you when it's complete."
        case .calendar: return "Checking your calendar now, sir."
        case .homeControl: return "Accessing smart home controls, sir."
        case .dailyBriefing: return "" // Handled dynamically
        case .fitness: return "" // Handled dynamically
        case .openApp: return "" // Handled dynamically
        case .navigate: return "" // Handled dynamically
        case .remember: return "I've committed that to memory, sir."
        case .executeProtocol: return "Initiating protocol sequence, sir."
        case .unknown: return "I didn't quite catch that, sir. Could you repeat your request?"
        }
    }
    
    var failureText: String {
        switch self {
        case .takePhoto: return "I'm afraid the camera capture failed, sir. Perhaps we should try again."
        case .showVideo: return "I couldn't locate any videos in your library, sir."
        case .recordNote: return "The audio recording encountered an issue, sir."
        case .getTime: return "I seem to have lost track of time, sir. My apologies."
        case .getDate: return "I'm having difficulty accessing the date, sir."
        case .getWeather: return "Weather services are currently unavailable, sir."
        case .setBrightness: return "I couldn't adjust the brightness, sir."
        case .setVolume: return "Volume adjustment failed, sir."
        case .playMusic: return "I'm unable to access your music library, sir."
        case .sendMessage: return "Message sending is not available, sir."
        case .setReminder: return "I couldn't set that reminder, sir."
        case .setTimer: return "I couldn't set that timer, sir."
        case .calendar: return "I couldn't access your calendar, sir."
        case .homeControl: return "HomeKit devices are not responding, sir."
        case .dailyBriefing: return "I couldn't compile your daily briefing, sir."
        case .fitness: return "I couldn't access your health data, sir."
        case .openApp: return "I couldn't open that app, sir."
        case .navigate: return "I couldn't start navigation, sir."
        case .remember: return "I was unable to save that memory, sir."
        case .executeProtocol: return "Protocol execution failed, sir."
        case .unknown: return "I'm afraid I couldn't process that request, sir."
        }
    }
}

// MARK: - Command Status
enum CommandStatus: String {
    case pending = "pending"
    case success = "success"
    case failed = "failed"
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .success: return Color("successGreen")
        case .failed: return .red
        }
    }
}

// MARK: - Command
struct Command: Identifiable {
    let id = UUID()
    let text: String
    let type: CommandType
    let timestamp: Date
    var status: CommandStatus
    
    init(text: String, type: CommandType, status: CommandStatus = .pending) {
        self.text = text
        self.type = type
        self.timestamp = Date()
        self.status = status
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - App State
enum AppState: String {
    case idle = "idle"
    case listening = "listening"
    case wakeDetected = "wake_detected"
    case processing = "processing"
    case speaking = "speaking"
    
    var displayText: String {
        switch self {
        case .idle: return "Offline"
        case .listening: return "Listening..."
        case .wakeDetected: return "Hey Jarvis!"
        case .processing: return "Processing..."
        case .speaking: return "Speaking..."
        }
    }
    
    var icon: String {
        switch self {
        case .idle: return "moon.fill"
        case .listening: return "waveform"
        case .wakeDetected: return "ear.fill"
        case .processing: return "brain.head.profile"
        case .speaking: return "speaker.wave.3.fill"
        }
    }
}
