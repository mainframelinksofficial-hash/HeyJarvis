//
//  TextToSpeechManager.swift
//  HeyJarvisApp
//
//  TTS facade with OpenAI primary and AVSpeech fallback
//

import Foundation
import AVFoundation

class TextToSpeechManager: NSObject {
    private let openAIManager: OpenAITTSManager
    private let speechSynthesizer: AVSpeechSynthesizer
    private var audioPlayer: AVAudioPlayer?
    private var completionHandler: (() -> Void)?
    
    override init() {
        self.openAIManager = OpenAITTSManager()
        self.speechSynthesizer = AVSpeechSynthesizer()
        super.init()
        self.speechSynthesizer.delegate = self
    }
    
    private var currentText: String = ""
    
    func speak(_ text: String, completion: (() -> Void)? = nil) {
        completionHandler = completion
        currentText = text
        
        Task {
            do {
                let audioData = try await openAIManager.synthesize(text: text)
                await playAudio(data: audioData)
            } catch {
                await fallbackToAVSpeech(text: text)
            }
        }
    }
    
    @MainActor
    private func playAudio(data: Data) async {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
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
