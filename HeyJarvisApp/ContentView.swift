//
//  ContentView.swift
//  HeyJarvisApp
//
//  Main UI with Stark Industries theme and Meta glasses integration
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @StateObject private var glassesManager = MetaGlassesManager.shared
    @State private var showVideoPlayer = false
    @State private var playerItem: AVPlayerItem?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("primaryDark"), Color("accentDark")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                glassesStatusView
                
                Spacer()
                
                StatusView(state: viewModel.appState)
                    .padding(.vertical, 20)
                
                transcriptionView
                
                jarvisResponseView
                
                Spacer()
                
                CommandHistoryView(commands: viewModel.commandHistory)
                    .frame(maxHeight: 180)
                
                controlButtons
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showVideoPlayer) {
            if let playerItem = playerItem {
                VideoPlayerView(playerItem: playerItem)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .playVideo)) { notification in
            if let item = notification.object as? AVPlayerItem {
                playerItem = item
                showVideoPlayer = true
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("HEY JARVIS")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Meta Glasses Companion")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("dimText"))
            }
            
            Spacer()
            
            Button {
                viewModel.showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color("jarvisBlue"))
            }
        }
        .padding(.top, 20)
    }
    
    private var glassesStatusView: some View {
        HStack(spacing: 12) {
            // Glasses connection indicator
            HStack(spacing: 8) {
                Image(systemName: glassesManager.isGlassesConnected ? "eyeglasses" : "eyeglasses")
                    .font(.system(size: 16))
                    .foregroundColor(glassesManager.isGlassesConnected ? Color("successGreen") : Color("dimText"))
                
                Text(glassesManager.connectionState.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(glassesManager.isGlassesConnected ? Color("successGreen") : Color("dimText"))
                
                if glassesManager.isGlassesConnected && glassesManager.batteryLevel > 0 {
                    Text("\(glassesManager.batteryLevel)%")
                        .font(.system(size: 11))
                        .foregroundColor(Color("dimText"))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
            
            // Background mode indicator
            if viewModel.isBackgroundModeEnabled {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color("successGreen"))
                        .frame(width: 8, height: 8)
                    
                    Text("Always On")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("successGreen"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color("successGreen").opacity(0.2))
                .cornerRadius(15)
            }
        }
        .padding(.top, 12)
    }
    
    private var transcriptionView: some View {
        VStack(spacing: 8) {
            if !viewModel.lastTranscription.isEmpty {
                Text("Heard:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("dimText"))
                
                Text(viewModel.lastTranscription)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
            }
        }
        .frame(height: 50)
    }
    
    private var jarvisResponseView: some View {
        VStack(spacing: 8) {
            if !viewModel.jarvisResponse.isEmpty {
                HStack(alignment: .top, spacing: 12) {
                    // JARVIS avatar
                    ZStack {
                        Circle()
                            .fill(Color("jarvisBlue").opacity(0.3))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 16))
                            .foregroundColor(Color("jarvisBlue"))
                    }
                    
                    // Speech bubble
                    VStack(alignment: .leading, spacing: 4) {
                        Text("JARVIS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color("jarvisBlue"))
                        
                        Text(viewModel.jarvisResponse)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(12)
                    .background(Color("accentDark"))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("jarvisBlue").opacity(0.3), lineWidth: 1)
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.3), value: viewModel.jarvisResponse)
            }
        }
        .frame(minHeight: 80)
        .padding(.vertical, 8)
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button {
                if viewModel.appState == .idle {
                    viewModel.startListening()
                } else {
                    viewModel.stopListening()
                }
            } label: {
                HStack {
                    Image(systemName: viewModel.appState == .idle ? "mic.fill" : "stop.fill")
                    Text(viewModel.appState == .idle ? "Start Listening" : "Stop")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color("jarvisBlue"), Color("jarvisBlue").opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: Color("jarvisBlue").opacity(0.4), radius: 10, x: 0, y: 5)
            }
            
            if !viewModel.commandHistory.isEmpty {
                Button {
                    viewModel.clearHistory()
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color("dimText"))
                        .padding(14)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(25)
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var glassesManager = MetaGlassesManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("primaryDark").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Meta Glasses Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meta Ray-Ban Glasses")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("dimText"))
                            
                            HStack {
                                Image(systemName: "eyeglasses")
                                    .font(.system(size: 20))
                                    .foregroundColor(glassesManager.isGlassesConnected ? Color("successGreen") : Color("jarvisBlue"))
                                
                                VStack(alignment: .leading) {
                                    Text(glassesManager.connectionState.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    if glassesManager.batteryLevel > 0 {
                                        Text("Battery: \(glassesManager.batteryLevel)%")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color("dimText"))
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    if glassesManager.isGlassesConnected {
                                        glassesManager.disconnect()
                                    } else {
                                        glassesManager.startSearching()
                                    }
                                } label: {
                                    Text(glassesManager.isGlassesConnected ? "Disconnect" : "Connect")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color("jarvisBlue"))
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color("accentDark"))
                        .cornerRadius(12)
                        
                        // API Configuration
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Groq API (TTS)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("dimText"))
                            
                            Text("Using Groq's fast PlayAI TTS for JARVIS voice. API key configured in JarvisVoiceSettings.plist")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color("accentDark"))
                        .cornerRadius(12)
                        
                        // Voice Commands
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Voice Commands")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("dimText"))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                commandRow(icon: "camera.fill", command: "\"Take a photo\"")
                                commandRow(icon: "play.rectangle.fill", command: "\"Show last video\"")
                                commandRow(icon: "mic.fill", command: "\"Record note\"")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color("accentDark"))
                        .cornerRadius(12)
                        
                        // Background Mode Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Always-On Listening")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("dimText"))
                            
                            Text("The app continues listening for \"Hey Jarvis\" even when minimized. Look for the Live Activity indicator on your Lock Screen.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color("accentDark"))
                        .cornerRadius(12)
                        
                        Spacer(minLength: 20)
                        
                        Text("Hey Jarvis v2.0 • com.AI.Jarvis")
                            .font(.system(size: 12))
                            .foregroundColor(Color("dimText"))
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
        }
    }
    
    private func commandRow(icon: String, command: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color("jarvisBlue"))
                .frame(width: 24)
            
            Text(command)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct VideoPlayerView: View {
    let playerItem: AVPlayerItem
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        player?.pause()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            player = AVPlayer(playerItem: playerItem)
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
