//
//  AppViewModel.swift
//  HeyJarvisApp
//
//  MVVM ViewModel managing app state and coordination
//

import SwiftUI
import Combine
import AVFoundation

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
    
    private var wakeWordDetector: WakeWordDetector?
    private var commandManager: CommandManager
    private var workflowController: MetaWorkflowController
    private var ttsManager: TextToSpeechManager
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.commandManager = CommandManager()
        self.workflowController = MetaWorkflowController()
        self.ttsManager = TextToSpeechManager()
        
        setupWakeWordDetector()
        setupBackgroundMode()
        setupMetaGlasses()
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
        // Configure audio session for background
        BackgroundAudioManager.shared.configureForBackground()
        
        // Observe app lifecycle
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
                self?.ttsManager.speak("Meta glasses connected, sir.")
                LiveActivityManager.shared.updateLiveActivity(
                    isListening: true,
                    lastCommand: "Glasses connected"
                )
            }
        }
        
        glassesManager.onGlassesDisconnected = { [weak self] in
            Task { @MainActor in
                self?.glassesConnected = false
            }
        }
        
        glassesManager.onPhotoRequested = { [weak self] in
            Task { @MainActor in
                self?.handleCommandReceived("take a photo")
            }
        }
        
        glassesManager.onVideoRequested = { [weak self] in
            Task { @MainActor in
                self?.handleCommandReceived("show last video")
            }
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
        // Restart listening if needed
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
                    // Configure for background
                    BackgroundAudioManager.shared.configureForBackground()
                    
                    try wakeWordDetector?.startListening()
                    appState = .listening
                    isBackgroundModeEnabled = true
                    
                    // Start Live Activity
                    LiveActivityManager.shared.startLiveActivity()
                    
                    // Start searching for Meta glasses
                    MetaGlassesManager.shared.startSearching()
                    
                } else {
                    errorMessage = "Microphone or speech recognition permission denied"
                }
            } catch {
                errorMessage = "Failed to start listening: \(error.localizedDescription)"
            }
        }
    }
    
    func stopListening() {
        wakeWordDetector?.stopListening()
        appState = .idle
        isBackgroundModeEnabled = false
        
        // Stop Live Activity
        LiveActivityManager.shared.stopLiveActivity()
        
        // Stop searching for glasses
        MetaGlassesManager.shared.stopSearching()
    }
    
    private func handleWakeWordDetected() {
        appState = .wakeDetected
        
        // Update Live Activity
        LiveActivityManager.shared.updateLiveActivity(
            isListening: true,
            lastCommand: "Wake word detected!"
        )
        
        ttsManager.speak("Yes, sir?") { [weak self] in
            Task { @MainActor in
                self?.appState = .listening
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            if self?.appState == .listening {
                self?.appState = .listening
            }
        }
    }
    
    private func handleCommandReceived(_ commandText: String) {
        appState = .processing
        
        // Update Live Activity
        LiveActivityManager.shared.updateLiveActivity(
            isListening: false,
            lastCommand: commandText
        )
        
        let commandType = commandManager.parseCommand(commandText)
        let command = Command(text: commandText, type: commandType)
        commandHistory.insert(command, at: 0)
        
        executeCommand(type: commandType, at: 0)
    }
    
    private func executeCommand(type commandType: CommandType, at index: Int) {
        Task {
            do {
                switch commandType {
                case .takePhoto:
                    // Try glasses first, then phone
                    if glassesConnected {
                        let success = await MetaGlassesManager.shared.triggerGlassesPhoto()
                        if !success {
                            try await workflowController.capturePhoto()
                        }
                    } else {
                        try await workflowController.capturePhoto()
                    }
                case .showVideo:
                    try await workflowController.showLastVideo()
                case .recordNote:
                    try await workflowController.recordNote()
                case .unknown:
                    break
                }
                
                await MainActor.run {
                    if index < self.commandHistory.count {
                        self.commandHistory[index].status = commandType == .unknown ? .failed : .success
                    }
                    self.speakResponse(for: commandType, success: commandType != .unknown)
                }
            } catch {
                await MainActor.run {
                    if index < self.commandHistory.count {
                        self.commandHistory[index].status = .failed
                    }
                    self.speakResponse(for: commandType, success: false)
                }
            }
        }
    }
    
    private func speakResponse(for commandType: CommandType, success: Bool) {
        appState = .speaking
        let text = success ? commandType.responseText : commandType.failureText
        
        // Update Live Activity
        LiveActivityManager.shared.updateLiveActivity(
            isListening: false,
            lastCommand: text
        )
        
        ttsManager.speak(text) { [weak self] in
            Task { @MainActor in
                self?.appState = .listening
                LiveActivityManager.shared.updateLiveActivity(
                    isListening: true,
                    lastCommand: "Listening..."
                )
            }
        }
    }
    
    func clearHistory() {
        commandHistory.removeAll()
    }
    
    func connectGlasses() {
        MetaGlassesManager.shared.startSearching()
    }
    
    func disconnectGlasses() {
        MetaGlassesManager.shared.disconnect()
        glassesConnected = false
    }
}
