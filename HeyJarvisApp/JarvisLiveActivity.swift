//
//  JarvisLiveActivity.swift
//  HeyJarvisApp
//
//  Live Activity for persistent "always listening" indicator
//

import ActivityKit
import AVFoundation
import SwiftUI
import UIKit

// MARK: - Live Activity Attributes
struct JarvisActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var isListening: Bool
        var lastCommand: String
        var glassesConnected: Bool
    }
    
    var sessionId: String
}

// MARK: - Live Activity Manager
@MainActor
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    @Published var isActivityRunning: Bool = false
    
    private init() {}
    
    func startLiveActivity() {
        print("Live Activity disabled for debugging")
    }
    
    func updateLiveActivity(isListening: Bool, lastCommand: String) {
        // No-op
    }
    
    func stopLiveActivity() {
        // No-op
    }
}

// MARK: - Background Audio Manager
class BackgroundAudioManager {
    static let shared = BackgroundAudioManager()
    
    private init() {}
    
    func configureForBackground() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Configure for background audio recording
            try audioSession.setCategory(
                .playAndRecord,
                mode: .measurement,
                options: [.duckOthers, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker, .mixWithOthers]
            )
            
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Request to keep running in background
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
            print("Background audio configured successfully")
        } catch {
            print("Failed to configure background audio: \(error)")
        }
    }
    
    func keepAlive() {
        // This helps keep the app alive in background by maintaining audio session
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}
