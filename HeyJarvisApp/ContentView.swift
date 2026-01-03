//
//  ContentView.swift
//  HeyJarvisApp
//
//  Main UI with Stark Industries theme
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
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
                
                Spacer()
                
                StatusView(state: viewModel.appState)
                    .padding(.vertical, 40)
                
                transcriptionView
                
                Spacer()
                
                CommandHistoryView(commands: viewModel.commandHistory)
                    .frame(maxHeight: 250)
                
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
        .frame(height: 60)
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("primaryDark").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("OpenAI API Key")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("dimText"))
                        
                        Text("Configure your API key in JarvisVoiceSettings.plist")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color("accentDark"))
                    .cornerRadius(12)
                    
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
                    
                    Spacer()
                    
                    Text("Hey Jarvis v1.0")
                        .font(.system(size: 12))
                        .foregroundColor(Color("dimText"))
                }
                .padding()
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
