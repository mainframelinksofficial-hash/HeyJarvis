//
//  OfflineManager.swift
//  HeyJarvisApp
//
//  Handles offline functionality when internet is unavailable
//
//  HOW IT WORKS:
//  1. Checks network connectivity
//  2. For offline: Uses on-device responses for basic commands
//  3. For online: Falls through to AI
//

import Network
import Foundation

class OfflineManager: ObservableObject {
    static let shared = OfflineManager()
    
    @Published var isOnline = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        startMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                print("JARVIS: Network status: \(path.status == .satisfied ? "Online" : "Offline")")
            }
        }
        monitor.start(queue: queue)
    }
    
    // MARK: - Offline Responses
    
    /// Get a response for commands that can work offline
    /// Returns nil if command requires internet
    func getOfflineResponse(for commandType: CommandType, text: String) -> String? {
        switch commandType {
        case .getTime:
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let timeString = formatter.string(from: Date())
            return "It's currently \(timeString), sir."
            
        case .getDate:
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            let dateString = formatter.string(from: Date())
            return "Today is \(dateString), sir."
            
        case .setTimer:
            // Timer works offline
            return TimerManager.shared.setTimer(from: text)
            
        case .playMusic:
            let lower = text.lowercased()
            if lower.contains("pause") || lower.contains("stop") {
                return MediaManager.shared.pauseMusic()
            } else if lower.contains("skip") || lower.contains("next") {
                return MediaManager.shared.skipTrack()
            } else {
                return MediaManager.shared.playMusic()
            }
            
        case .setBrightness:
            return "I'm sorry, sir, but iOS doesn't permit third-party applications to adjust screen brightness directly."
            
        case .setVolume:
            return "Volume control requires direct system access, sir. Please use your device's volume buttons."
            
        case .openApp:
            return AppLauncherManager.shared.launchApp(from: text)
            
        case .navigate:
            let destination = text.lowercased()
                .replacingOccurrences(of: "navigate to", with: "")
                .replacingOccurrences(of: "take me to", with: "")
                .trimmingCharacters(in: .whitespaces)
            return AppLauncherManager.shared.navigateTo(destination: destination)
            
        case .homeControl:
            let lower = text.lowercased()
            if lower.contains("on") {
                return HomeManager.shared.toggleLights(on: true)
            } else if lower.contains("off") {
                return HomeManager.shared.toggleLights(on: false)
            } else {
                return HomeManager.shared.checkLightStatus()
            }
            
        default:
            // These commands require internet
            return nil
        }
    }
    
    /// Check if a command can work offline
    func canWorkOffline(_ commandType: CommandType) -> Bool {
        switch commandType {
        case .getTime, .getDate, .setTimer, .playMusic, 
             .setBrightness, .setVolume, .openApp, .navigate, .homeControl:
            return true
        default:
            return false
        }
    }
    
    /// Get offline unavailable message
    func getOfflineMessage() -> String {
        return "I'm currently offline, sir. I can still help with time, date, timers, music control, and opening apps. For AI conversations and weather, I'll need an internet connection."
    }
}
