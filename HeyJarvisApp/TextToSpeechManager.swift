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
    }
    
    func speak(_ text: String, completion: (() -> Void)? = nil) {
        completionHandler = completion
        currentText = text
        
        // Route audio to Meta glasses if connected
        MetaGlassesManager.shared.routeAudioToGlasses()
        
        Task {
            do {
                let audioData = try await groqManager.synthesize(text: text)
                await playAudio(data: audioData)
            } catch {
                print("Groq TTS failed: \(error), falling back to AVSpeech")
                await fallbackToAVSpeech(text: text)
            }
        }
    }
    
    @MainActor
    private func playAudio(data: Data) async {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            fallbackToAVSpeechSync(text: currentText)
        }
    }
    
    @MainActor
    private func fallbackToAVSpeech(text: String) async {
        fallbackToAVSpeechSync(text: text)
    }
    
    private func fallbackToAVSpeechSync(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        // Use formal British voice for JARVIS character
        if let britishVoice = AVSpeechSynthesisVoice(language: "en-GB") {
            utterance.voice = britishVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 0.85
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
        DispatchQueue.main.async {
            self.completionHandler?()
            self.completionHandler = nil
        }
    }
}

extension TextToSpeechManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.completionHandler?()
            self.completionHandler = nil
        }
    }
}
