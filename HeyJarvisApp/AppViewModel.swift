//
//  AppViewModel.swift
//  HeyJarvisApp
//
//  MVVM ViewModel managing app state and coordination
//

import SwiftUI
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .idle
    @Published var commandHistory: [Command] = []
    @Published var lastTranscription: String = ""
    @Published var isPermissionGranted: Bool = false
    @Published var showSettings: Bool = false
    @Published var errorMessage: String?
    
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
    
    func startListening() {
        Task {
            do {
                let granted = try await wakeWordDetector?.requestPermissions() ?? false
                isPermissionGranted = granted
                
                if granted {
                    try wakeWordDetector?.startListening()
                    appState = .listening
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
    }
    
    private func handleWakeWordDetected() {
        appState = .wakeDetected
        
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
                    try await workflowController.capturePhoto()
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
        
        ttsManager.speak(text) { [weak self] in
            Task { @MainActor in
                self?.appState = .listening
            }
        }
    }
    
    func clearHistory() {
        commandHistory.removeAll()
    }
}
