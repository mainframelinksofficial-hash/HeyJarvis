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
    @State private var showConversationHistory = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("primaryDark"), Color("accentDark")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            
            VStack(spacing: 0) {
                HeaderView(
                    showHistory: $showConversationHistory,
                    showSettings: $viewModel.showSettings
                )
                
                GlassesStatusView(
                    glassesManager: glassesManager,
                    isBackgroundModeEnabled: viewModel.isBackgroundModeEnabled
                )
                
                Spacer()
                
                // The Mind (Dynamic Core)
                JarvisMindView()
                    .frame(height: 250)
                    .padding(.vertical, 20)
                
                TranscriptionView(text: viewModel.lastTranscription)
                
                JarvisResponseView(responseText: viewModel.jarvisResponse)
                
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
        .sheet(isPresented: $showConversationHistory) {
            ConversationHistoryView()
                .environmentObject(viewModel)
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
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button {
                SoundManager.shared.playImpact() // Heavier sound for main action
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
            .simultaneousGesture(TapGesture().onEnded {
               // Fallback if action handler doesn't trigger immediately
            })
            
            if !viewModel.commandHistory.isEmpty {
                Button {
                    SoundManager.shared.playClick()
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
// SettingsView moved to Views/SettingsView.swift

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
                        SoundManager.shared.playClick()
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
