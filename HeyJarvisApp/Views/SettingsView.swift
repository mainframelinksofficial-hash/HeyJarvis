//
//  SettingsView.swift
//  HeyJarvisApp
//
//  Premium settings with voice selection, speed, and customization
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var glassesManager = MetaGlassesManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("primaryDark").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Voice Settings
                        SettingsSection(title: "Voice", icon: "speaker.wave.3.fill") {
                            VStack(spacing: 16) {
                                // Voice Selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("JARVIS Voice")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color("dimText"))
                                    
                                    Picker("Voice", selection: $settings.selectedVoice) {
                                        ForEach(JarvisVoice.allCases, id: \.self) { voice in
                                            Text(voice.displayName).tag(voice)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(Color("jarvisBlue"))
                                }
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                // Speech Speed
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Speech Speed")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color("dimText"))
                                        Spacer()
                                        Text(String(format: "%.1fx", settings.speechSpeed))
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color("jarvisBlue"))
                                    }
                                    
                                    Slider(value: $settings.speechSpeed, in: 0.5...2.0, step: 0.1)
                                        .tint(Color("jarvisBlue"))
                                }
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                // Test Voice Button
                                Button {
                                    settings.testVoice()
                                } label: {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                        Text("Test Voice")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color("jarvisBlue"))
                                }
                            }
                        }
                        
                        // Sound Effects
                        SettingsSection(title: "Sound Effects", icon: "waveform") {
                            VStack(spacing: 16) {
                                SettingsToggle(
                                    title: "Startup Sound",
                                    subtitle: "Play sound when JARVIS goes online",
                                    isOn: $settings.startupSoundEnabled
                                )
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                SettingsToggle(
                                    title: "Confirmation Beeps",
                                    subtitle: "Beep on command completion",
                                    isOn: $settings.confirmationBeepsEnabled
                                )
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                SettingsToggle(
                                    title: "HUD Sounds",
                                    subtitle: "Iron Man interface sounds",
                                    isOn: $settings.hudSoundsEnabled
                                )
                            }
                        }
                        
                        // Haptics
                        SettingsSection(title: "Haptics", icon: "iphone.radiowaves.left.and.right") {
                            VStack(spacing: 16) {
                                SettingsToggle(
                                    title: "Haptic Feedback",
                                    subtitle: "Vibrate on wake word and commands",
                                    isOn: $settings.hapticFeedbackEnabled
                                )
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Haptic Intensity")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color("dimText"))
                                    
                                    Picker("Intensity", selection: $settings.hapticIntensity) {
                                        Text("Light").tag(HapticIntensity.light)
                                        Text("Medium").tag(HapticIntensity.medium)
                                        Text("Strong").tag(HapticIntensity.strong)
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                        }
                        
                        // Meta Glasses
                        SettingsSection(title: "Meta Glasses", icon: "eyeglasses") {
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Connection Status")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        Text(glassesManager.connectionState.rawValue)
                                            .font(.system(size: 12))
                                            .foregroundColor(glassesManager.isGlassesConnected ? Color("successGreen") : Color("dimText"))
                                    }
                                    
                                    Spacer()
                                    
                                    Circle()
                                        .fill(glassesManager.isGlassesConnected ? Color("successGreen") : Color.gray)
                                        .frame(width: 12, height: 12)
                                }
                                
                                if glassesManager.isGlassesConnected {
                                    Divider().background(Color.white.opacity(0.1))
                                    
                                    HStack {
                                        Text("Battery Level")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(glassesManager.batteryLevel)%")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color("jarvisBlue"))
                                    }
                                }
                                
                                Button {
                                    if glassesManager.isGlassesConnected {
                                        glassesManager.disconnect()
                                    } else {
                                        glassesManager.startSearching()
                                    }
                                } label: {
                                    Text(glassesManager.isGlassesConnected ? "Disconnect" : "Search for Glasses")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(glassesManager.isGlassesConnected ? .red : Color("jarvisBlue"))
                                }
                            }
                        }
                        
                        // About
                        SettingsSection(title: "About", icon: "info.circle.fill") {
                            VStack(spacing: 12) {
                                AboutRow(label: "Version", value: "2.0.0")
                                AboutRow(label: "Build", value: "2026.01.04")
                                AboutRow(label: "Developer", value: "Stark Industries")
                            }
                        }
                        
                        // Reset Button
                        Button {
                            settings.resetToDefaults()
                        } label: {
                            Text("Reset to Defaults")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("jarvisBlue"))
                }
            }
            .toolbarBackground(Color("primaryDark"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color("jarvisBlue"))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            content
                .padding()
                .background(Color("accentDark"))
                .cornerRadius(16)
        }
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(Color("dimText"))
            }
        }
        .tint(Color("jarvisBlue"))
    }
}

// MARK: - About Row
struct AboutRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("dimText"))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SettingsView()
}
