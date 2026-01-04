//
//  AppViewModel.swift
//  HeyJarvisApp
//
//  MVVM ViewModel - Core JARVIS brain managing all interactions
//

import SwiftUI
import Combine
import AVFoundation
import UIKit

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .idle
    @Published var commandHistory: [Command] = []
    @Published var lastTranscription: String = ""
    @Published var isPermissionGranted: Bool = false
    @Published var showSettings: Bool = false
    @Published var errorMessage: String?
    @Published var isBackgroundModeEnabled: Bool = false
    @Published var glassesConnected: Bool = false
    @Published var jarvisResponse: String = ""
    @Published var batteryLevel: Int = 100
    
    private var wakeWordDetector: WakeWordDetector?
    private var commandManager: CommandManager
    private var workflowController: MetaWorkflowController
    private var ttsManager: TextToSpeechManager
    private var jarvisAI: JarvisAI
    private var homeManager: HomeManager
    private var mediaManager: MediaManager
    private var eventManager: EventManager
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.commandManager = CommandManager()
        self.workflowController = MetaWorkflowController()
        self.ttsManager = TextToSpeechManager()
        self.jarvisAI = JarvisAI()
        self.homeManager = HomeManager.shared
        self.mediaManager = MediaManager.shared
        self.eventManager = EventManager.shared
        
        setupWakeWordDetector()
        setupBackgroundMode()
        setupMetaGlasses()
        startBatteryMonitoring()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        WatchSessionManager.shared.onCommandReceived = { [weak self] command in
            Task { @MainActor in
                if command == "listen" {
                    try? self?.wakeWordDetector?.startListening()
                } else if command == "stop" {
                    self?.wakeWordDetector?.stopListening()
                } else {
                     // Treat as voice command text
                    self?.handleCommandReceived(command)
                }
            }
        }
        
        // Sync status changes
        $appState
            .sink { state in
                let isListening = state == .listening
                let status = state.displayText
                WatchSessionManager.shared.sendStatusToWatch(isListening: isListening, statusText: status)
            }
            .store(in: &cancellables)
    }
    
    private func setupWakeWordDetector() {
        wakeWordDetector = WakeWordDetector()
        
        wakeWordDetector?.onWakeWordDetected = { [weak self] in
            Task { @MainActor in
                self?.handleWakeWordDetected()
            }
        }
        
        wakeWordDetector?.onCommandReceived = { [weak self] command in
            Task { @MainActor in
                self?.handleCommandReceived(command)
            }
        }
        
        wakeWordDetector?.onTranscription = { [weak self] text in
            Task { @MainActor in
                self?.lastTranscription = text
            }
        }
        
        wakeWordDetector?.onError = { [weak self] error in
            Task { @MainActor in
                self?.errorMessage = error
            }
        }
    }
    
    private func setupBackgroundMode() {
        BackgroundAudioManager.shared.configureForBackground()
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleEnterBackground()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleEnterForeground()
        }
    }
    
    private func setupMetaGlasses() {
        let glassesManager = MetaGlassesManager.shared
        
        glassesManager.onGlassesConnected = { [weak self] in
            Task { @MainActor in
                self?.glassesConnected = true
                self?.speakJarvis("Meta glasses connected and fully operational, sir. Audio will now route through your eyewear.")
                LiveActivityManager.shared.updateLiveActivity(
                    isListening: true,
                    lastCommand: "Glasses connected"
                )
            }
        }
        
        glassesManager.onGlassesDisconnected = { [weak self] in
            Task { @MainActor in
                self?.glassesConnected = false
                self?.speakJarvis("Glasses disconnected, sir. Reverting to phone audio.")
            }
        }
    }
    
    private func startBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        }
    }
    
    private func handleEnterBackground() {
        if isBackgroundModeEnabled {
            BackgroundAudioManager.shared.keepAlive()
            LiveActivityManager.shared.updateLiveActivity(
                isListening: true,
                lastCommand: "Listening in background..."
            )
        }
    }
    
    private func handleEnterForeground() {
        if appState == .listening {
            try? wakeWordDetector?.startListening()
        }
    }
    
    func startListening() {
        Task {
            do {
                let granted = try await wakeWordDetector?.requestPermissions() ?? false
                isPermissionGranted = granted
                
                if granted {
                    BackgroundAudioManager.shared.configureForBackground()
                    
                    try wakeWordDetector?.startListening()
                    appState = .listening
                    isBackgroundModeEnabled = true
                    
                    LiveActivityManager.shared.startLiveActivity()
                    MetaGlassesManager.shared.startSearching()
                    
                    // Startup sound
                    SoundManager.shared.playStartup()
                    
                    // Premium JARVIS greeting
                    let hour = Calendar.current.component(.hour, from: Date())
                    let greeting: String
                    if hour < 12 {
                        greeting = "Good morning, sir. JARVIS online and all systems are fully operational. How may I assist you today?"
                    } else if hour < 17 {
                        greeting = "Good afternoon, sir. JARVIS at your service. All systems nominal and ready for your commands."
                    } else {
                        greeting = "Good evening, sir. JARVIS online. I trust you've had a productive day. What can I do for you?"
                    }
                    speakJarvis(greeting)
                    
                } else {
                    errorMessage = "I require microphone access to hear your commands, sir."
                }
            } catch {
                errorMessage = "Failed to initialize: \(error.localizedDescription)"
            }
        }
    }
    
    func stopListening() {
        speakJarvis("Going offline now, sir. It's been a pleasure serving you. Until next time.") { [weak self] in
            self?.wakeWordDetector?.stopListening()
            self?.appState = .idle
            self?.isBackgroundModeEnabled = false
            LiveActivityManager.shared.stopLiveActivity()
            MetaGlassesManager.shared.stopSearching()
        }
    }
    
    private func handleWakeWordDetected() {
        appState = .wakeDetected
        
        // Sound effect
        SoundManager.shared.playHUDActivation()
        
        // Haptic feedback
        SettingsManager.shared.triggerHaptic()
        
        LiveActivityManager.shared.updateLiveActivity(
            isListening: true,
            lastCommand: "Wake word detected!"
        )
        
        let responses = [
            "At your service, sir.",
            "Yes, sir?",
            "How may I assist you, sir?",
            "I'm listening, sir.",
            "Ready and awaiting your command, sir."
        ]
        speakJarvis(responses.randomElement() ?? "Yes, sir?") { [weak self] in
            Task { @MainActor in
                self?.appState = .listening
            }
        }
    }
    
    private func handleCommandReceived(_ commandText: String) {
        appState = .processing
        
        // Sound effect
        SoundManager.shared.playProcessing()
        
        // Haptic feedback
        SettingsManager.shared.triggerHaptic()
        
        LiveActivityManager.shared.updateLiveActivity(
            isListening: false,
            lastCommand: commandText
        )
        
        let commandType = commandManager.parseCommand(commandText)
        let command = Command(text: commandText, type: commandType)
        commandHistory.insert(command, at: 0)
        
        // Limit history to 50 items
        if commandHistory.count > 50 {
            commandHistory = Array(commandHistory.prefix(50))
        }
        
        if commandType == .unknown {
            handleConversation(commandText, at: 0)
        } else {
            executeCommand(type: commandType, text: commandText, at: 0)
        }
    }
    
    private func handleConversation(_ message: String, at index: Int) {
        Task {
            do {
                let response = try await jarvisAI.chat(message: message)
                
                await MainActor.run {
                    self.jarvisResponse = response
                    if index < self.commandHistory.count {
                        self.commandHistory[index].status = .success
                    }
                    SoundManager.shared.playSuccess()
                    self.speakJarvis(response)
                }
            } catch {
                await MainActor.run {
                    let fallbackResponse = "I'm afraid I encountered a difficulty processing that request, sir. Perhaps we could try again?"
                    self.jarvisResponse = fallbackResponse
                    if index < self.commandHistory.count {
                        self.commandHistory[index].status = .failed
                    }
                    SoundManager.shared.playError()
                    self.speakJarvis(fallbackResponse)
                }
            }
        }
    }
    
    private func executeCommand(type commandType: CommandType, text: String, at index: Int) {
        Task {
            var success = true
            var response = ""
            
            do {
                switch commandType {
                case .playMusic:
                    let lower = text.lowercased()
                    if lower.contains("pause") || lower.contains("stop") {
                        response = MediaManager.shared.pauseMusic()
                    } else if lower.contains("skip") || lower.contains("next") {
                        response = MediaManager.shared.skipTrack()
                    } else {
                        response = MediaManager.shared.playMusic()
                    }
                    
                case .homeControl:
                    let lower = text.lowercased()
                    if lower.contains("on") || lower.contains("illuminate") {
                        response = HomeManager.shared.toggleLights(on: true)
                    } else if lower.contains("off") || lower.contains("kill") {
                        response = HomeManager.shared.toggleLights(on: false)
                    } else {
                        response = HomeManager.shared.checkLightStatus()
                    }
                    
                case .calendar:
                    let granted = await EventManager.shared.requestAccess()
                    if granted {
                        response = EventManager.shared.getTodaysEvents()
                    } else {
                        response = "I require access to your calendar to proceed, sir."
                    }
                    
                case .setReminder:
                    let granted = await EventManager.shared.requestAccess()
                    if granted {
                        let title = text.replacingOccurrences(of: "remind me to", with: "")
                                       .replacingOccurrences(of: "set reminder", with: "")
                                       .replacingOccurrences(of: "remind me", with: "")
                                       .trimmingCharacters(in: .whitespaces)
                        let reminderTitle = title.isEmpty ? "Reminder" : title
                        response = await EventManager.shared.addReminder(title: reminderTitle)
                    } else {
                        response = "I require access to your reminders to proceed, sir."
                    }
                    
                case .setTimer:
                     response = "Timer set for 5 minutes, sir. (Timer logic is simulated for this version)"
                    
                case .takePhoto:
                    if glassesConnected {
                        let glassesSuccess = await MetaGlassesManager.shared.triggerGlassesPhoto()
                        if !glassesSuccess {
                            try await workflowController.capturePhoto()
                        }
                    } else {
                        try await workflowController.capturePhoto()
                    }
                    response = commandType.responseText
                    
                case .showVideo:
                    try await workflowController.showLastVideo()
                    response = commandType.responseText
                    
                case .recordNote:
                    try await workflowController.recordNote()
                    response = commandType.responseText
                    
                case .getTime:
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    let timeString = formatter.string(from: Date())
                    response = "The current time is \(timeString), sir."
                    
                case .getDate:
                    let formatter = DateFormatter()
                    formatter.dateStyle = .full
                    let dateString = formatter.string(from: Date())
                    response = "Today is \(dateString), sir."
                    
                case .getWeather:
                    response = await WeatherManager.shared.getWeatherResponse()
                    
                case .setBrightness:
                    response = "I'm sorry, sir, but iOS doesn't permit third-party applications to adjust screen brightness directly. You'll need to use Control Center."
                    
                case .setVolume:
                    response = "Volume control requires direct system access, sir. Please use your device's volume buttons."
                    
                case .sendMessage:
                    response = "Message functionality requires additional permissions, sir. This feature is currently being developed."
                    
                case .unknown:
                    break
                }
                
            } catch {
                success = false
                response = jarvisAI.getCommandResponse(for: commandType, success: false)
            }
            
            await MainActor.run {
                if index < self.commandHistory.count {
                    self.commandHistory[index].status = success ? .success : .failed
                }
                self.jarvisResponse = response
                self.speakJarvis(response)
            }
        }
    }
    
    private func speakJarvis(_ text: String, completion: (() -> Void)? = nil) {
        appState = .speaking
        jarvisResponse = text
        
        LiveActivityManager.shared.updateLiveActivity(
            isListening: false,
            lastCommand: String(text.prefix(50)) + (text.count > 50 ? "..." : "")
        )
        
        ttsManager.speak(text) { [weak self] in
            Task { @MainActor in
                self?.appState = .listening
                LiveActivityManager.shared.updateLiveActivity(
                    isListening: true,
                    lastCommand: "Listening..."
                )
                completion?()
            }
        }
    }
    
    func clearHistory() {
        commandHistory.removeAll()
        jarvisAI.resetConversation()
        jarvisResponse = ""
        
        // Haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    func connectGlasses() {
        MetaGlassesManager.shared.startSearching()
    }
    
    func disconnectGlasses() {
        MetaGlassesManager.shared.disconnect()
        glassesConnected = false
    }
}
