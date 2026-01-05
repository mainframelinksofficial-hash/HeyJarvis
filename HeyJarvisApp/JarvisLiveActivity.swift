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
    
    @Published var currentActivity: Activity<JarvisActivityAttributes>?
    @Published var isActivityRunning: Bool = false
    
    private init() {}
    
    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not enabled")
            return
        }
        
        let attributes = JarvisActivityAttributes(sessionId: UUID().uuidString)
        let initialState = JarvisActivityAttributes.ContentState(
            isListening: true,
            lastCommand: "Ready",
            glassesConnected: MetaGlassesManager.shared.isGlassesConnected
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            isActivityRunning = true
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateLiveActivity(isListening: Bool, lastCommand: String) {
        Task {
            let updatedState = JarvisActivityAttributes.ContentState(
                isListening: isListening,
                lastCommand: lastCommand,
                glassesConnected: MetaGlassesManager.shared.isGlassesConnected
            )
            
            await currentActivity?.update(
                ActivityContent(state: updatedState, staleDate: nil)
            )
        }
    }
    
    func stopLiveActivity() {
        Task {
            let finalState = JarvisActivityAttributes.ContentState(
                isListening: false,
                lastCommand: "Stopped",
                glassesConnected: false
            )
            
            await currentActivity?.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate
            )
            currentActivity = nil
            isActivityRunning = false
        }
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
