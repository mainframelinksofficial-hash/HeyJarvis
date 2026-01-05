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

// MARK: - Wake Word Sensitivity
enum WakeWordSensitivity: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High (Recommended)"
        }
    }
    
    var silenceTimeout: Double {
        switch self {
        case .low: return 4.0
        case .medium: return 3.0
        case .high: return 2.0
        }
    }
}

// MARK: - Response Length
enum ResponseLength: String, CaseIterable {
    case brief = "brief"
    case normal = "normal"
    case detailed = "detailed"
    
    var displayName: String {
        switch self {
        case .brief: return "Brief"
        case .normal: return "Normal"
        case .detailed: return "Detailed"
        }
    }
    
    var systemPromptAddition: String {
        switch self {
        case .brief: return "Keep responses very short and concise, 1-2 sentences max."
        case .normal: return "Keep responses moderate in length."
        case .detailed: return "Provide detailed, thorough responses when appropriate."
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
    
// MARK: - AI Personality
enum JarvisPersonality: String, CaseIterable {
    case professional = "professional"
    case sarcastic = "sarcastic"
    case friendly = "friendly"
    
    var displayName: String {
        switch self {
        case .professional: return "Professional (Classic)"
        case .sarcastic: return "Sarcastic (Tony Stark Mode)"
        case .friendly: return "Friendly (Casual)"
        }
    }
    
    var promptModifier: String {
        switch self {
        case .professional: 
            return "You are unfailingly polite, formal, and British. Address the user as 'sir'. Be concise and efficient."
        case .sarcastic: 
            return "You have a dry, witty, and slightly sarcastic personality. You are still helpful, but you make quips. Channel Tony Stark's AI."
        case .friendly: 
            return "You are warm, casual, and enthusiastic. You use exclamation marks and are very encouraging. Use first names if known."
        }
    var promptModifier: String {
        switch self {
        case .professional: 
            return "You are unfailingly polite, formal, and British. Address the user as 'sir'. Be concise and efficient."
        case .sarcastic: 
            return "You have a dry, witty, and slightly sarcastic personality. You are still helpful, but you make quips. Channel Tony Stark's AI."
        case .friendly: 
            return "You are warm, casual, and enthusiastic. You use exclamation marks and are very encouraging. Use first names if known."
        }
    }
}

// MARK: - Sound Theme
enum SoundTheme: String, CaseIterable {
    case jarvis = "jarvis"
    case friday = "friday"
    case scifi = "scifi"
    
    var displayName: String {
        switch self {
        case .jarvis: return "JARVIS (Classic)"
        case .friday: return "F.R.I.D.A.Y. (Soft)"
        case .scifi: return "Retro Sci-Fi"
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
        static let wakeWordSensitivity = "wakeWordSensitivity"
        static let responseLength = "responseLength"
        static let autoStopTimer = "autoStopTimer"
        static let customWakeWord = "customWakeWord"
        static let rememberConversations = "rememberConversations"
        static let vibrateOnResponse = "vibrateOnResponse"
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
    
    // Wake Word Settings
    @Published var wakeWordSensitivity: WakeWordSensitivity {
        didSet { defaults.set(wakeWordSensitivity.rawValue, forKey: Keys.wakeWordSensitivity) }
    }
    
    @Published var customWakeWord: String {
        didSet { defaults.set(customWakeWord, forKey: Keys.customWakeWord) }
    }
    
    // AI Settings
    @Published var responseLength: ResponseLength {
        didSet { defaults.set(responseLength.rawValue, forKey: Keys.responseLength) }
    }
    
    @Published var rememberConversations: Bool {
        didSet { defaults.set(rememberConversations, forKey: Keys.rememberConversations) }
    }
    
    // Additional Settings
    @Published var vibrateOnResponse: Bool {
        didSet { defaults.set(vibrateOnResponse, forKey: Keys.vibrateOnResponse) }
    }
    
    @Published var selectedPersonality: JarvisPersonality {
        didSet { defaults.set(selectedPersonality.rawValue, forKey: "selectedPersonality") }
    }
    
    @Published var selectedSoundTheme: SoundTheme {
        didSet { defaults.set(selectedSoundTheme.rawValue, forKey: "selectedSoundTheme") }
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
        
        // New settings
        self.wakeWordSensitivity = WakeWordSensitivity(rawValue: defaults.string(forKey: Keys.wakeWordSensitivity) ?? "") ?? .medium
        self.customWakeWord = defaults.string(forKey: Keys.customWakeWord) ?? "hey jarvis"
        self.responseLength = ResponseLength(rawValue: defaults.string(forKey: Keys.responseLength) ?? "") ?? .normal
        self.rememberConversations = defaults.object(forKey: Keys.rememberConversations) as? Bool ?? true
        self.vibrateOnResponse = defaults.object(forKey: Keys.vibrateOnResponse) as? Bool ?? false
        self.selectedPersonality = JarvisPersonality(rawValue: defaults.string(forKey: "selectedPersonality") ?? "") ?? .professional
        self.selectedSoundTheme = SoundTheme(rawValue: defaults.string(forKey: "selectedSoundTheme") ?? "") ?? .jarvis
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
        wakeWordSensitivity = .medium
        customWakeWord = "hey jarvis"
        responseLength = .normal
        rememberConversations = true
        vibrateOnResponse = false
        
        // Play confirmation
        SoundManager.shared.playConfirmation()
        triggerHaptic()
    }
    
    func triggerHaptic() {
        guard hapticFeedbackEnabled else { return }
        
        // Dynamic Haptics based on Personality
        var style: UIImpactFeedbackGenerator.FeedbackStyle = hapticIntensity.feedbackStyle
        
        // Override style based on personality to give "character"
        switch selectedPersonality {
        case .professional:
            // Respects user setting exactly (Medium default)
            break 
        case .sarcastic:
            // Sarcastic is sharper, heavier
            if style == .medium { style = .heavy }
            else if style == .light { style = .medium }
        case .friendly:
            // Friendly is lighter, bouncier
            if style == .heavy { style = .medium }
            else if style == .medium { style = .light }
        }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func triggerNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticFeedbackEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
