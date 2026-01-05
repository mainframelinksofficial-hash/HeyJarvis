//
//  TextToSpeechManager.swift
//  HeyJarvisApp
//
//  TTS facade with Groq primary and AVSpeech fallback
//

import Foundation
import AVFoundation

class TextToSpeechManager: NSObject {
    private let groqManager: GroqTTSManager
    private let speechSynthesizer: AVSpeechSynthesizer
    private var audioPlayer: AVAudioPlayer?
    private var completionHandler: (() -> Void)?
    private var currentText: String = ""
    
    override init() {
        self.groqManager = GroqTTSManager()
        self.speechSynthesizer = AVSpeechSynthesizer()
        super.init()
        self.speechSynthesizer.delegate = self
        
        // Configure audio session on init
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP, .duckOthers])
            try audioSession.setActive(true)
            print("JARVIS Audio: Session configured")
        } catch {
            print("JARVIS Audio: Failed to configure session: \(error)")
        }
    }
    
    func speak(_ text: String, completion: (() -> Void)? = nil) {
        completionHandler = completion
        currentText = text
        
        print("JARVIS TTS: Speaking: \(text)")
        
        // Route audio to Meta glasses if connected
        MetaGlassesManager.shared.routeAudioToGlasses()
        
        Task {
            do {
                print("JARVIS TTS: Attempting Groq synthesis...")
                let audioData = try await groqManager.synthesize(text: text)
                print("JARVIS TTS: Got \(audioData.count) bytes, playing...")
                await playAudio(data: audioData)
            } catch {
                print("JARVIS TTS: Groq failed with error: \(error)")
                print("JARVIS TTS: Falling back to AVSpeech")
                await fallbackToAVSpeech(text: text)
            }
        }
    }
    
    @MainActor
    private func playAudio(data: Data) async {
        do {
            // Re-configure audio session before playback
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            
            // Stop any existing playback
            audioPlayer?.stop()
            
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            
            let played = audioPlayer?.play() ?? false
            print("JARVIS TTS: Audio playback started: \(played)")
            
            if !played {
                print("JARVIS TTS: Playback failed, falling back")
                fallbackToAVSpeechSync(text: currentText)
            }
        } catch {
            print("JARVIS TTS: AVAudioPlayer error: \(error)")
            fallbackToAVSpeechSync(text: currentText)
        }
    }
    
    @MainActor
    private func fallbackToAVSpeech(text: String) async {
        fallbackToAVSpeechSync(text: text)
    }
    
    private func fallbackToAVSpeechSync(text: String) {
        print("JARVIS TTS: Using AVSpeech for: \(text)")
        
        let utterance = AVSpeechUtterance(string: text)
        let personality = SettingsManager.shared.selectedPersonality
        
        // Try to find the best voice based on personality
        let voices = AVSpeechSynthesisVoice.speechVoices()
        var preferredVoice: AVSpeechSynthesisVoice?
        
        switch personality {
        case .professional, .sarcastic:
            // British voices for JARVIS/Sarcastic
            preferredVoice = voices.first { $0.language == "en-GB" && $0.quality == .enhanced }
                ?? voices.first { $0.language == "en-GB" }
        case .friendly:
            // American voice for Friendly
            preferredVoice = voices.first { $0.language == "en-US" && $0.quality == .enhanced }
                ?? voices.first { $0.language == "en-US" }
        }
        
        utterance.voice = preferredVoice ?? AVSpeechSynthesisVoice(language: "en-US")
        
        // Adjust params based on personality
        switch personality {
        case .professional:
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9 // Slower, intentional
            utterance.pitchMultiplier = 0.85 // Deeper
        case .sarcastic:
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95 // Slightly faster than professional
            utterance.pitchMultiplier = 0.9 // Slightly higher
        case .friendly:
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1.05 // Energetic
            utterance.pitchMultiplier = 1.1 // Brighter
        }
        
        // Apply user speed override if set
        // (If you want to respect the 'Speech Speed' setting on top of this)
        let userSpeed = Float(SettingsManager.shared.speechSpeed)
        utterance.rate *= userSpeed
        
        utterance.volume = 1.0
        
        DispatchQueue.main.async {
            self.speechSynthesizer.speak(utterance)
        }
    }
    
    func stop() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
    }
}

extension TextToSpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("JARVIS TTS: AVSpeech finished")
        DispatchQueue.main.async {
            self.completionHandler?()
            self.completionHandler = nil
        }
    }
}

extension TextToSpeechManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("JARVIS TTS: Audio playback finished, success: \(flag)")
        DispatchQueue.main.async {
            self.completionHandler?()
            self.completionHandler = nil
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("JARVIS TTS: Decode error: \(error?.localizedDescription ?? "unknown")")
        fallbackToAVSpeechSync(text: currentText)
    }
}
