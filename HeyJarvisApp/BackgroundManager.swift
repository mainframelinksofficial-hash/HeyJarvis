//
//  BackgroundManager.swift
//  HeyJarvisApp
//
//  Manages persistent background running for always-on mode
//
//  HOW IT WORKS:
//  1. Configures audio session to stay active in background
//  2. Plays silent audio to keep app alive
//  3. Uses background tasks for periodic refresh
//  4. Shows notification when always-on is enabled
//

import AVFoundation
import BackgroundTasks
import UserNotifications
import UIKit

class BackgroundManager: ObservableObject {
    static let shared = BackgroundManager()
    
    @Published var isAlwaysOnEnabled = false
    
    private var audioPlayer: AVAudioPlayer?
    private var silenceTimer: Timer?
    
    private init() {
        // Load saved preference
        isAlwaysOnEnabled = UserDefaults.standard.bool(forKey: "alwaysOnMode")
    }
    
    // MARK: - Always-On Mode
    
    /// Enable always-on mode - keeps JARVIS running in background
    func enableAlwaysOn() {
        isAlwaysOnEnabled = true
        UserDefaults.standard.set(true, forKey: "alwaysOnMode")
        
        // Configure audio session for background
        configureAudioSession()
        
        // Start silent audio to keep app alive
        startSilentAudio()
        
        // Show persistent notification
        showAlwaysOnNotification()
        
        // Register for background refresh
        registerBackgroundTasks()
        
        print("JARVIS: Always-on mode enabled")
    }
    
    /// Disable always-on mode
    func disableAlwaysOn() {
        isAlwaysOnEnabled = false
        UserDefaults.standard.set(false, forKey: "alwaysOnMode")
        
        // Stop silent audio
        stopSilentAudio()
        
        // Remove notification
        removeAlwaysOnNotification()
        
        print("JARVIS: Always-on mode disabled")
    }
    
    /// Toggle always-on mode
    func toggle() {
        if isAlwaysOnEnabled {
            disableAlwaysOn()
        } else {
            enableAlwaysOn()
        }
    }
    
    // MARK: - Audio Session
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            // Use playAndRecord category with mixWithOthers option
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker]
            )
            
            // Activate the session
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("JARVIS: Audio session configured for background")
        } catch {
            print("JARVIS: Audio session error: \(error)")
        }
    }
    
    // MARK: - Silent Audio (Keeps app alive)
    
    private func startSilentAudio() {
        // Create a silent audio file programmatically
        // This keeps the audio session active in background
        
        // For now, we'll use a timer to periodically "touch" the audio session
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.keepAlive()
        }
        
        // Fire immediately
        keepAlive()
    }
    
    private func stopSilentAudio() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func keepAlive() {
        // Touch the audio session to keep it active
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("JARVIS: Keep-alive error: \(error)")
        }
    }
    
    // MARK: - Notifications
    
    private func showAlwaysOnNotification() {
        let content = UNMutableNotificationContent()
        content.title = "JARVIS Active"
        content.body = "Always-on mode enabled. Say 'Hey Jarvis' anytime."
        content.sound = nil // Silent notification
        content.categoryIdentifier = "ALWAYS_ON"
        
        // Create a repeating trigger (every hour as a reminder)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "jarvis_always_on",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func removeAlwaysOnNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["jarvis_always_on"]
        )
        UNUserNotificationCenter.current().removeDeliveredNotifications(
            withIdentifiers: ["jarvis_always_on"]
        )
    }
    
    // MARK: - Background Tasks
    
    private func registerBackgroundTasks() {
        // Register refresh task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.AI.Jarvis.refresh",
            using: nil
        ) { task in
            if let refreshTask = task as? BGAppRefreshTask {
                self.handleBackgroundRefresh(task: refreshTask)
            }
        }
        
        // Schedule the task
        scheduleBackgroundRefresh()
    }
    
    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.AI.Jarvis.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("JARVIS: Background task error: \(error)")
        }
    }
    
    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        // Schedule next refresh
        scheduleBackgroundRefresh()
        
        // Keep the audio session alive
        keepAlive()
        
        // Complete the task
        task.setTaskCompleted(success: true)
    }
    
    // MARK: - App Lifecycle
    
    func handleAppDidEnterBackground() {
        if isAlwaysOnEnabled {
            configureAudioSession()
            startSilentAudio()
        }
    }
    
    func handleAppWillEnterForeground() {
        // Refresh audio session
        if isAlwaysOnEnabled {
            configureAudioSession()
        }
    }
}
