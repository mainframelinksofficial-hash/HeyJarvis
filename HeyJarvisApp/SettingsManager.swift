//
//  SettingsManager.swift
//  HeyJarvisApp
//
//  Manages user preferences with persistence
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - Voice Options
enum JarvisVoice: String, CaseIterable {
    case fritz = "Fritz-PlayAI"
    case arista = "Arista-PlayAI"
    case atlas = "Atlas-PlayAI"
    case basil = "Basil-PlayAI"
    case briggs = "Briggs-PlayAI"
    case cove = "Cove-PlayAI"
    
    var displayName: String {
        switch self {
        case .fritz: return "Fritz (Default)"
        case .arista: return "Arista"
        case .atlas: return "Atlas"
        case .basil: return "Basil"
        case .briggs: return "Briggs"
        case .cove: return "Cove"
        }
    }
}

// MARK: - Haptic Intensity
enum HapticIntensity: String, CaseIterable {
    case light = "light"
    case medium = "medium"
    case strong = "strong"
    
    var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light: return .light
        case .medium: return .medium
        case .strong: return .heavy
        }
    }
}

// MARK: - Settings Manager
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    // Keys
    private enum Keys {
        static let selectedVoice = "selectedVoice"
        static let speechSpeed = "speechSpeed"
        static let startupSound = "startupSoundEnabled"
        static let confirmationBeeps = "confirmationBeepsEnabled"
        static let hudSounds = "hudSoundsEnabled"
        static let hapticFeedback = "hapticFeedbackEnabled"
        static let hapticIntensity = "hapticIntensity"
    }
    
    // Voice Settings
    @Published var selectedVoice: JarvisVoice {
        didSet { defaults.set(selectedVoice.rawValue, forKey: Keys.selectedVoice) }
    }
    
    @Published var speechSpeed: Double {
        didSet { defaults.set(speechSpeed, forKey: Keys.speechSpeed) }
    }
    
    // Sound Effects
    @Published var startupSoundEnabled: Bool {
        didSet { defaults.set(startupSoundEnabled, forKey: Keys.startupSound) }
    }
    
    @Published var confirmationBeepsEnabled: Bool {
        didSet { defaults.set(confirmationBeepsEnabled, forKey: Keys.confirmationBeeps) }
    }
    
    @Published var hudSoundsEnabled: Bool {
        didSet { defaults.set(hudSoundsEnabled, forKey: Keys.hudSounds) }
    }
    
    // Haptics
    @Published var hapticFeedbackEnabled: Bool {
        didSet { defaults.set(hapticFeedbackEnabled, forKey: Keys.hapticFeedback) }
    }
    
    @Published var hapticIntensity: HapticIntensity {
        didSet { defaults.set(hapticIntensity.rawValue, forKey: Keys.hapticIntensity) }
    }
    
    private var ttsManager: TextToSpeechManager?
    
    private init() {
        // Load saved values or use defaults
        self.selectedVoice = JarvisVoice(rawValue: defaults.string(forKey: Keys.selectedVoice) ?? "") ?? .fritz
        self.speechSpeed = defaults.double(forKey: Keys.speechSpeed) != 0 ? defaults.double(forKey: Keys.speechSpeed) : 1.0
        self.startupSoundEnabled = defaults.object(forKey: Keys.startupSound) as? Bool ?? true
        self.confirmationBeepsEnabled = defaults.object(forKey: Keys.confirmationBeeps) as? Bool ?? true
        self.hudSoundsEnabled = defaults.object(forKey: Keys.hudSounds) as? Bool ?? true
        self.hapticFeedbackEnabled = defaults.object(forKey: Keys.hapticFeedback) as? Bool ?? true
        self.hapticIntensity = HapticIntensity(rawValue: defaults.string(forKey: Keys.hapticIntensity) ?? "") ?? .medium
    }
    
    func testVoice() {
        if ttsManager == nil {
            ttsManager = TextToSpeechManager()
        }
        ttsManager?.speak("At your service, sir. JARVIS is fully operational and ready to assist you.")
    }
    
    func resetToDefaults() {
        selectedVoice = .fritz
        speechSpeed = 1.0
        startupSoundEnabled = true
        confirmationBeepsEnabled = true
        hudSoundsEnabled = true
        hapticFeedbackEnabled = true
        hapticIntensity = .medium
        
        // Play confirmation
        SoundManager.shared.playConfirmation()
        triggerHaptic()
    }
    
    func triggerHaptic() {
        guard hapticFeedbackEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: hapticIntensity.feedbackStyle)
        generator.impactOccurred()
    }
    
    func triggerNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticFeedbackEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
