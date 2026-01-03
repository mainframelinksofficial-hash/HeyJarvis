//
//  WakeWordDetector.swift
//  HeyJarvisApp
//
//  Continuous speech recognition for wake word detection
//

import Foundation
import Speech
import AVFoundation

class WakeWordDetector: NSObject {
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var isListeningForCommand = false
    private var commandBuffer = ""
    private var silenceTimer: Timer?
    
    var onWakeWordDetected: (() -> Void)?
    var onCommandReceived: ((String) -> Void)?
    var onTranscription: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    private let wakeWords = ["hey jarvis", "hey jarvis", "a jarvis", "hey travis", "hey jervis"]
    
    override init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        super.init()
        self.speechRecognizer?.delegate = self
    }
    
    func requestPermissions() async throws -> Bool {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        guard speechStatus == .authorized else {
            return false
        }
        
        let audioStatus = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        return audioStatus
    }
    
    func startListening() throws {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw NSError(domain: "WakeWordDetector", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available"])
        }
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "WakeWordDetector", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false
        
        if #available(iOS 16.0, *) {
            recognitionRequest.addsPunctuation = false
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        startRecognitionTask()
    }
    
    private func startRecognitionTask() {
        guard let speechRecognizer = speechRecognizer,
              let recognitionRequest = recognitionRequest else { return }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let transcription = result.bestTranscription.formattedString.lowercased()
                
                DispatchQueue.main.async {
                    self.onTranscription?(transcription)
                }
                
                if self.isListeningForCommand {
                    self.handleCommandMode(transcription: transcription, isFinal: result.isFinal)
                } else {
                    self.checkForWakeWord(in: transcription)
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
                self.restartListening()
            }
            
            if result?.isFinal == true {
                self.restartListening()
            }
        }
    }
    
    private func checkForWakeWord(in transcription: String) {
        for wakeWord in wakeWords {
            if transcription.contains(wakeWord) {
                isListeningForCommand = true
                commandBuffer = ""
                
                DispatchQueue.main.async {
                    self.onWakeWordDetected?()
                }
                
                startSilenceTimer()
                break
            }
        }
    }
    
    private func handleCommandMode(transcription: String, isFinal: Bool) {
        var cleanedTranscription = transcription
        for wakeWord in wakeWords {
            cleanedTranscription = cleanedTranscription.replacingOccurrences(of: wakeWord, with: "")
        }
        cleanedTranscription = cleanedTranscription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !cleanedTranscription.isEmpty {
            commandBuffer = cleanedTranscription
            resetSilenceTimer()
        }
        
        if isFinal && !commandBuffer.isEmpty {
            finalizeCommand()
        }
    }
    
    private func startSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.finalizeCommand()
        }
    }
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        startSilenceTimer()
    }
    
    private func finalizeCommand() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        
        let command = commandBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !command.isEmpty {
            DispatchQueue.main.async {
                self.onCommandReceived?(command)
            }
        }
        
        isListeningForCommand = false
        commandBuffer = ""
    }
    
    private func restartListening() {
        stopListening()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            do {
                try self?.startListening()
            } catch {
                self?.onError?("Failed to restart listening: \(error.localizedDescription)")
            }
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        silenceTimer?.invalidate()
        silenceTimer = nil
        isListeningForCommand = false
    }
}

extension WakeWordDetector: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            DispatchQueue.main.async {
                self.onError?("Speech recognition is not available")
            }
        }
    }
}
