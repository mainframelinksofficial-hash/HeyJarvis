//
//  SoundManager.swift
//  HeyJarvisApp
//
//  Iron Man style sound effects for JARVIS
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var synthesizer: AVSpeechSynthesizer?
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        } catch {
            print("SoundManager: Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - Sound Effects using System Sounds
    
    /// Play startup chime when JARVIS goes online
    func playStartup() {
        guard SettingsManager.shared.startupSoundEnabled else { return }
        playSystemSound(id: 1117) // Tink sound - clean activation
    }
    
    /// Play confirmation beep on command completion
    func playConfirmation() {
        guard SettingsManager.shared.confirmationBeepsEnabled else { return }
        playSystemSound(id: 1054) // Subtle confirmation
    }
    
    /// Play success sound
    func playSuccess() {
        guard SettingsManager.shared.confirmationBeepsEnabled else { return }
        playSystemSound(id: 1025) // Success tone
    }
    
    /// Play error/failure sound
    func playError() {
        guard SettingsManager.shared.confirmationBeepsEnabled else { return }
        playSystemSound(id: 1053) // Error beep
    }
    
    /// Play HUD activation sound (wake word detected)
    func playHUDActivation() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        playSystemSound(id: 1113) // Tech activation sound
    }
    
    /// Play HUD deactivation sound
    func playHUDDeactivation() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        playSystemSound(id: 1114) // Tech deactivation
    }
    
    /// Play listening indicator
    func playListening() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        playSystemSound(id: 1110) // Subtle ping
    }
    
    /// Play processing sound
    func playProcessing() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        playSystemSound(id: 1103) // Processing tick
    }
    
    // MARK: - System Sound Helper
    
    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
    
    // MARK: - Stop
    
    func stopAll() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

// MARK: - Audio Services Import
import AudioToolbox
