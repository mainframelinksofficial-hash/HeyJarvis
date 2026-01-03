//
//  Command.swift
//  HeyJarvisApp
//
//  Data models for command processing
//

import Foundation

enum CommandType: String, CaseIterable {
    case takePhoto = "Take Photo"
    case showVideo = "Show Video"
    case recordNote = "Record Note"
    case unknown = "Unknown Command"
    
    var icon: String {
        switch self {
        case .takePhoto: return "camera.fill"
        case .showVideo: return "play.rectangle.fill"
        case .recordNote: return "mic.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    var responseText: String {
        switch self {
        case .takePhoto: return "Photo saved, sir."
        case .showVideo: return "Playing now, sir."
        case .recordNote: return "Note saved, sir."
        case .unknown: return "I didn't understand that command, sir."
        }
    }
    
    var failureText: String {
        switch self {
        case .takePhoto: return "Unable to capture photo, sir."
        case .showVideo: return "Unable to play video, sir."
        case .recordNote: return "Unable to record note, sir."
        case .unknown: return "Command not recognized, sir."
        }
    }
}

enum CommandStatus: String {
    case pending = "Pending"
    case success = "Success"
    case failed = "Failed"
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "jarvisBlue"
        case .success: return "successGreen"
        case .failed: return "errorRed"
        }
    }
}

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

enum AppState: String {
    case idle = "Idle"
    case listening = "Listening"
    case wakeDetected = "Wake Detected"
    case processing = "Processing"
    case speaking = "Speaking"
    
    var statusText: String {
        switch self {
        case .idle: return "Say \"Hey Jarvis\" to begin"
        case .listening: return "Listening for wake word..."
        case .wakeDetected: return "Yes, sir?"
        case .processing: return "Processing command..."
        case .speaking: return "Speaking..."
        }
    }
}
