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
import WidgetKit

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
        setupLifecycleObservers()
        
        // Check immediately on launch
        checkPendingQuery()
    }
    
    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkPendingQuery()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("QuickActionCommand"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let command = notification.object as? String {
                self?.handleQuickActionCommand(command)
            }
        }
        
        // Play immersive startup sound
        SoundManager.shared.playStartup()
    }
    
    private func handleQuickActionCommand(_ command: String) {
        if command == "listen" {
            startListening()
        } else {
            handleCommandReceived(command)
        }
    }
    
    private func checkPendingQuery() {
        let defaults = UserDefaults(suiteName: "group.com.AI.Jarvis")
        
        // 1. Check for pending voice commands
        if let query = defaults?.string(forKey: "pendingQuery") {
            // Clear it so we don't run it twice
            defaults?.removeObject(forKey: "pendingQuery")
            
            // Execute command
            handleCommandReceived(query)
        }
        
        // 2. Sync Light State from Widget
        if let lightsOn = defaults?.bool(forKey: "lightsAreOn") {
            // We just ask HomeManager to set the state. 
            // It will check actual status and update if needed.
            // Note: We don't speak the response here to avoid annoyance on every open
            _ = HomeManager.shared.toggleLights(on: lightsOn)
        }
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
                    syncToWidget()
                    
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
            self?.isBackgroundModeEnabled = false
            LiveActivityManager.shared.stopLiveActivity()
            MetaGlassesManager.shared.stopSearching()
            self?.syncToWidget()
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
        
        syncToWidget()
        
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
                    SettingsManager.shared.triggerNotificationHaptic(.success)
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
                    SettingsManager.shared.triggerNotificationHaptic(.error)
                    self.speakJarvis(fallbackResponse)
                }
            }
        }
    }
    
    private func executeCommand(type commandType: CommandType, text: String, at index: Int) {
        Task {
            var success = true
            var response = ""
            
            // Check for offline-capable commands first
            if !OfflineManager.shared.isOnline {
                if let offlineResponse = OfflineManager.shared.getOfflineResponse(for: commandType, text: text) {
                    response = offlineResponse
                } else {
                    response = OfflineManager.shared.getOfflineMessage()
                    success = false
                }
                
                // Update UI and speak
                await MainActor.run {
                    if index < self.commandHistory.count {
                        self.commandHistory[index].status = success ? .success : .failed
                    }
                    self.jarvisResponse = response
                    self.speakJarvis(response)
                }
                return
            }
            
            do {
                switch commandType {
                case .playMusic:
                    let lower = text.lowercased()
                    if lower.contains("pause") || lower.contains("stop") {
                        response = MediaManager.shared.pauseMusic()
                    } else if lower.contains("skip") || lower.contains("next") {
                        response = MediaManager.shared.skipTrack()
                    } else if lower.contains("spotify") {
                        // Open Spotify app
                        response = MediaManager.shared.openSpotify()
                    } else {
                        response = MediaManager.shared.playMusic()
                    }
                    
                case .homeControl:
                    let lower = text.lowercased()
                    if lower.contains("on") || lower.contains("illuminate") {
                        response = HomeManager.shared.toggleLights(on: true)
                    } else if lower.contains("off") || lower.contains("kill") {
                        response = HomeManager.shared.toggleLights(on: false)
                    } else if lower.contains("scene") || lower.contains("activate") || lower.contains("mode") {
                        // Extract scene name and activate it
                        let sceneName = lower.replacingOccurrences(of: "activate", with: "")
                                            .replacingOccurrences(of: "scene", with: "")
                                            .replacingOccurrences(of: "mode", with: "")
                                            .trimmingCharacters(in: .whitespaces)
                        if sceneName.isEmpty {
                            response = HomeManager.shared.listScenes()
                        } else {
                            response = HomeManager.shared.activateScene(named: sceneName)
                        }
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
                    // Real timer using TimerManager
                    response = TimerManager.shared.setTimer(from: text)
                    
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
                    
                case .dailyBriefing:
                    // Get combined briefing from BriefingManager
                    response = await BriefingManager.shared.getDailyBriefing()
                    
                case .fitness:
                    // Get fitness data from HealthManager
                    let lower = text.lowercased()
                    if lower.contains("heart") {
                        response = await HealthManager.shared.getLatestHeartRate()
                    } else {
                        response = await HealthManager.shared.getTodaySteps()
                    }
                    
                case .openApp:
                    // Open third-party apps
                    response = AppLauncherManager.shared.launchApp(from: text)
                    
                case .navigate:
                    // Navigation
                    let destination = text.lowercased()
                        .replacingOccurrences(of: "navigate to", with: "")
                        .replacingOccurrences(of: "take me to", with: "")
                        .replacingOccurrences(of: "directions to", with: "")
                        .replacingOccurrences(of: "drive to", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    if destination.isEmpty {
                        response = "Where would you like to go, sir?"
                    } else {
                        response = AppLauncherManager.shared.navigateTo(destination: destination)
                    }
                    
                case .remember:
                    // Extract the memory content
                    let lower = text.lowercased()
                    let memory = text
                        .replacingOccurrences(of: "remember that", with: "", options: .caseInsensitive)
                        .replacingOccurrences(of: "remember this", with: "", options: .caseInsensitive)
                        .replacingOccurrences(of: "don't forget", with: "", options: .caseInsensitive)
                        .replacingOccurrences(of: "memorize", with: "", options: .caseInsensitive)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if memory.isEmpty {
                        response = "What would you like me to remember, sir?"
                    } else {
                        MemoryManager.shared.addFact(memory)
                        response = commandType.responseText
                    }
                    
                case .executeProtocol:
                    // Find the matching protocol
                    if let proto = ProtocolManager.shared.checkTrigger(text) {
                        // Execute actions
                        for action in proto.actions {
                            switch action.type {
                            case .lights:
                                let _ = await HomeManager.shared.toggleLights(on: action.value != "off")
                                
                            case .volume:
                                // Simulate volume change
                                if let vol = Float(action.value) {
                                    // Simulating system volume change
                                    print("Setting volume to \(vol)")
                                }
                                
                            case .music:
                                // Launch music if needed
                                let _ = AppLauncherManager.shared.launchApp(from: "spotify")
                                
                            case .say:
                                // This will be handled by the response override below
                                break
                                
                            case .wait:
                                // Parse wait time (default 1s)
                                let seconds = Double(action.value) ?? 1.0
                                let nanoseconds = UInt64(seconds * 1_000_000_000)
                                try? await Task.sleep(nanoseconds: nanoseconds)
                                
                            case .lock:
                                // Simulate lock
                                print("Locking doors...")
                            }
                        }
                        
                        // Set custom response if defined, otherwise default
                        if let customResponse = proto.response {
                            response = customResponse
                        } else if let sayAction = proto.actions.first(where: { $0.type == .say }) {
                            response = sayAction.value
                        } else {
                            response = "Protocol \(proto.name) executed successfully, sir."
                        }
                    } else {
                        response = "Protocol verified but could not be initiated, sir."
                    }
                    
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
                self?.syncToWidget()
                completion?()
            }
        }
    }
    
    private func syncToWidget() {
        let defaults = UserDefaults(suiteName: "group.com.AI.Jarvis")
        defaults?.set(appState == .listening || appState == .processing || appState == .speaking, forKey: "isListening")
        defaults?.set(commandHistory.first?.text ?? "Ready", forKey: "lastCommand")
        defaults?.set(commandHistory.count, forKey: "commandCount")
        
        // Force widget reload
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func addToHistory(_ command: Command) {
        commandHistory.append(command)
        
        // Hardening: Prevent memory leaks by capping history
        if commandHistory.count > 50 {
            commandHistory.removeFirst(commandHistory.count - 50)
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
