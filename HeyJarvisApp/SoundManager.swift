//
//  SoundManager.swift
//  HeyJarvisApp
//
//  Iron Man style sound effects for JARVIS
//

/// Manages all audio feedback, sound themes, and tactile UI sounds for the JARVIS system.
import Foundation
import AVFoundation

class SoundManager {
    /// Global shared instance for sound playback.
    static let shared = SoundManager()
    
    // Low-level audio engine for system sounds
    private var audioPlayer: AVAudioPlayer?
    
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
        switch SettingsManager.shared.selectedSoundTheme {
        case .jarvis: playSystemSound(id: 1117)
        case .friday: playSystemSound(id: 1001)
        case .scifi: playSystemSound(id: 1322)
        }
    }
    
    /// Play confirmation beep on command completion
    func playConfirmation() {
        guard SettingsManager.shared.confirmationBeepsEnabled else { return }
        switch SettingsManager.shared.selectedSoundTheme {
        case .jarvis: playSystemSound(id: 1054)
        case .friday: playSystemSound(id: 1016)
        case .scifi: playSystemSound(id: 1306)
        }
    }
    
    /// Play success sound
    func playSuccess() {
        guard SettingsManager.shared.confirmationBeepsEnabled else { return }
        switch SettingsManager.shared.selectedSoundTheme {
        case .jarvis: playSystemSound(id: 1025)
        case .friday: playSystemSound(id: 1323)
        case .scifi: playSystemSound(id: 1334)
        }
    }
    
    /// Play error/failure sound
    func playError() {
        guard SettingsManager.shared.confirmationBeepsEnabled else { return }
        switch SettingsManager.shared.selectedSoundTheme {
        case .jarvis: playSystemSound(id: 1053)
        case .friday: playSystemSound(id: 1003)
        case .scifi: playSystemSound(id: 1336)
        }
    }
    
    /// Play HUD activation sound (wake word detected)
    func playHUDActivation() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        switch SettingsManager.shared.selectedSoundTheme {
        case .jarvis: playSystemSound(id: 1113)
        case .friday: playSystemSound(id: 1109)
        case .scifi: playSystemSound(id: 1303)
        }
    }
    
    /// Play HUD deactivation sound
    func playHUDDeactivation() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        switch SettingsManager.shared.selectedSoundTheme {
        case .jarvis: playSystemSound(id: 1114)
        case .friday: playSystemSound(id: 1111)
        case .scifi: playSystemSound(id: 1304)
        }
    }
    
    /// Play listening indicator
    func playListening() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        playSystemSound(id: 1110)
    }
    
    /// Play processing sound
    func playProcessing() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        playSystemSound(id: 1103)
    }
    
    // MARK: - System Sound Helper
    
    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
    
    // MARK: - Tactile UI Feedback
    
    /// Crisp mechanical click for buttons
    func playClick() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        // System Sound 1104 is the standard "Tock" sound
        playSystemSound(id: 1104)
    }
    
    /// Light tick for toggles/sliders
    func playTick() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        // System Sound 1105 is the "Tink" sound
        playSystemSound(id: 1105)
    }
    
    /// Heavier impact for major actions
    func playImpact() {
        guard SettingsManager.shared.hudSoundsEnabled else { return }
        // System Sound 1004 is a subtle impact
        playSystemSound(id: 1004)
    }
    
    // MARK: - Stop
    
    func stopAll() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

// MARK: - Audio Services Import
import AudioToolbox
