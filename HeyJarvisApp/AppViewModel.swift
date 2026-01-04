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
    @Published var jarvisResponse: String = ""
    
    private var wakeWordDetector: WakeWordDetector?
    private var commandManager: CommandManager
    private var workflowController: MetaWorkflowController
    private var ttsManager: TextToSpeechManager
    private var jarvisAI: JarvisAI
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.commandManager = CommandManager()
        self.workflowController = MetaWorkflowController()
        self.ttsManager = TextToSpeechManager()
        self.jarvisAI = JarvisAI()
        
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
                self?.speakJarvis("Meta glasses connected and operational, sir. All systems are online.")
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
                    
                    // JARVIS greeting
                    speakJarvis("JARVIS online, sir. All systems operational. How may I assist you?")
                    
                } else {
                    errorMessage = "Microphone or speech recognition permission denied"
                }
            } catch {
                errorMessage = "Failed to start listening: \(error.localizedDescription)"
            }
        }
    }
    
    func stopListening() {
        speakJarvis("Going offline, sir. It was a pleasure serving you.") { [weak self] in
            self?.wakeWordDetector?.stopListening()
            self?.appState = .idle
            self?.isBackgroundModeEnabled = false
            LiveActivityManager.shared.stopLiveActivity()
            MetaGlassesManager.shared.stopSearching()
        }
    }
    
    private func handleWakeWordDetected() {
        appState = .wakeDetected
        
        LiveActivityManager.shared.updateLiveActivity(
            isListening: true,
            lastCommand: "Wake word detected!"
        )
        
        speakJarvis("At your service, sir.") { [weak self] in
            Task { @MainActor in
                self?.appState = .listening
            }
        }
    }
    
    private func handleCommandReceived(_ commandText: String) {
        appState = .processing
        
        LiveActivityManager.shared.updateLiveActivity(
            isListening: false,
            lastCommand: commandText
        )
        
        let commandType = commandManager.parseCommand(commandText)
        let command = Command(text: commandText, type: commandType)
        commandHistory.insert(command, at: 0)
        
        if commandType == .unknown {
            // Use JARVIS AI for conversational response
            handleConversation(commandText, at: 0)
        } else {
            // Execute known command
            executeCommand(type: commandType, at: 0)
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
                    self.speakJarvis(response)
                }
            } catch {
                await MainActor.run {
                    let fallbackResponse = "I'm afraid I encountered a difficulty, sir. Perhaps we could try again?"
                    self.jarvisResponse = fallbackResponse
                    if index < self.commandHistory.count {
                        self.commandHistory[index].status = .failed
                    }
                    self.speakJarvis(fallbackResponse)
                }
            }
        }
    }
    
    private func executeCommand(type commandType: CommandType, at index: Int) {
        Task {
            do {
                switch commandType {
                case .takePhoto:
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
                        self.commandHistory[index].status = .success
                    }
                    let response = self.jarvisAI.getCommandResponse(for: commandType, success: true)
                    self.jarvisResponse = response
                    self.speakJarvis(response)
                }
            } catch {
                await MainActor.run {
                    if index < self.commandHistory.count {
                        self.commandHistory[index].status = .failed
                    }
                    let response = self.jarvisAI.getCommandResponse(for: commandType, success: false)
                    self.jarvisResponse = response
                    self.speakJarvis(response)
                }
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
    }
    
    func connectGlasses() {
        MetaGlassesManager.shared.startSearching()
    }
    
    func disconnectGlasses() {
        MetaGlassesManager.shared.disconnect()
        glassesConnected = false
    }
}
