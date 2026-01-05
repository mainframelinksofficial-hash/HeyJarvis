```
//
//  SettingsView.swift
//  HeyJarvisApp
//
//  "The Iron Man HUD"
//  A premium, glassmorphic settings console for JARVIS.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var glassesManager = MetaGlassesManager.shared
    @StateObject private var protocolManager = ProtocolManager.shared
    @StateObject private var systemMonitor = SystemMonitor.shared // Real-time stats
    @State private var showCommandReference = false
    
    // Animation constants
    @State private var pulse = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Grid/Tech overlay
                VStack {
                    Divider().background(Color("jarvisBlue").opacity(0.3))
                    Spacer()
                    Divider().background(Color("jarvisBlue").opacity(0.3))
                }
                .padding(.vertical, 50)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - Header / Diagnostics
                        HStack(spacing: 12) {
                            // User Profile / Connection
                            HUDCard {
                                VStack(alignment: .leading) {
                                    Text("SYSTEM STATUS")
                                        .font(.caption2)
                                        .foregroundColor(Color("jarvisBlue"))
                                        .tracking(1)
                                    
                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                            .shadow(color: .green, radius: 4)
                                            .opacity(pulse ? 1.0 : 0.5)
                                        Text("ONLINE")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .layoutPriority(1)
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Text("BATTERY")
                                                .font(.system(size: 8))
                                                .foregroundColor(.gray)
                                            Text(systemMonitor.batteryLevel)
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(batteryColor)
                                        }
                                    }
                                }
                            }
                            
                            // Real Memory Usage
                            HUDCard {
                                VStack(alignment: .leading) {
                                    Text("MEMORY CORE")
                                        .font(.caption2)
                                        .foregroundColor(Color("jarvisBlue"))
                                        .tracking(1)
                                    
                                    Text(systemMonitor.ramUsage)
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 2)
                                    
                                    HStack(alignment: .bottom, spacing: 2) {
                                        ForEach(0..<10) { i in
                                            RoundedRectangle(cornerRadius: 1)
                                                .fill(Color("jarvisBlue").opacity(Double(i)/10.0 + 0.2))
                                                .frame(height: pulse ? CGFloat.random(in: 10...30) : CGFloat.random(in: 10...30))
                                                .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i)*0.05), value: pulse)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Voice Module
                        HUDSection(title: "VOICE MODULE") {
                            VStack(spacing: 16) {
                                HStack {
// ... rest of the view remains same as before, just ensuring we replace the header ...
                                    VStack(alignment: .leading) {
                                        Text("AI VOICE")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Picker("Voice", selection: $settings.selectedVoice) {
                                            ForEach(JarvisVoice.allCases, id: \.self) { voice in
                                                Text(voice.displayName).tag(voice)
                                            }
                                        }
                                        .tint(Color("jarvisBlue"))
                                        .labelsHidden()
                                    }
                                    Spacer()
                                    Button(action: { settings.testVoice() }) {
                                        Image(systemName: "waveform")
                                            .foregroundColor(Color("jarvisBlue"))
                                            .padding(10)
                                            .background(Color("jarvisBlue").opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                                
                                HStack {
                                    Text("SPEED")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "%.1fx", settings.speechSpeed))
                                        .font(.caption)
                                        .foregroundColor(Color("jarvisBlue"))
                                }
                                Slider(value: $settings.speechSpeed, in: 0.5...2.0, step: 0.1)
                                    .tint(Color("jarvisBlue"))
                            }
                        }
                        
                        // MARK: - Personality Matrix
                        HUDSection(title: "PERSONALITY MATRIX") {
                            VStack(spacing: 12) {
                                Picker("Personality", selection: $settings.selectedPersonality) {
                                    ForEach(JarvisPersonality.allCases, id: \.self) { mode in
                                        Text(mode.displayName).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .colorMultiply(Color("jarvisBlue"))
                                
                                Text(settings.selectedPersonality == .sarcastic ? "WARNING: Sarcasm levels set to maximum." : "Standard personality loaded.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // MARK: - Custom Protocols (New)
                        HUDSection(title: "PROTOCOLS (MACROS)") {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(protocolManager.protocols) { proto in
                                    HStack {
                                        Image(systemName: "bolt.fill")
                                            .foregroundColor(.yellow)
                                        VStack(alignment: .leading) {
                                            Text(proto.name)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("Trigger: \"\(proto.triggerPhrase)\"")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(8)
                                }
                                
                                Button(action: { /* Add Protocol logic would go here */ }) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Create New Protocol")
                                    }
                                    .font(.caption)
                                    .foregroundColor(Color("jarvisBlue"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 4)
                                }
                            }
                        }
                        
                        // MARK: - Systems (Sound, Haptics, Glasses)
                        HStack(alignment: .top, spacing: 12) {
                            HUDSection(title: "AUDIO") {
                                Toggle("Sounds", isOn: $settings.hudSoundsEnabled)
                                    .tint(Color("jarvisBlue"))
                                Toggle("Startup", isOn: $settings.startupSoundEnabled)
                                    .tint(Color("jarvisBlue"))
                            }
                            
                            HUDSection(title: "HAPTICS") {
                                Toggle("Feedback", isOn: $settings.hapticFeedbackEnabled)
                                    .tint(Color("jarvisBlue"))
                                Picker("Intensity", selection: $settings.hapticIntensity) {
                                    Text("L").tag(HapticIntensity.light)
                                    Text("M").tag(HapticIntensity.medium)
                                    Text("H").tag(HapticIntensity.strong)
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        
                        // MARK: - Help
                        Button(action: { showCommandReference = true }) {
                            Text("ACCESS COMMAND DATABASE")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("jarvisBlue"))
                                .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulse.toggle()
                }
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showCommandReference) {
            CommandReferenceView()
        }
    }
    }
    
    private var batteryColor: Color {
        let level = systemMonitor.batteryLevel.replacingOccurrences(of: "%", with: "")
        if let percent = Int(level) {
            if percent <= 20 { return .red }
            if percent <= 50 { return .yellow }
        }
        return Color("successGreen")
    }
}

// MARK: - HUD Components

struct HUDCard<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("jarvisBlue").opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

struct HUDSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color("jarvisBlue"))
                .tracking(2)
                .padding(.leading, 4)
            
            HUDCard {
                content
            }
        }
    }
}

#Preview {
    SettingsView()
}
