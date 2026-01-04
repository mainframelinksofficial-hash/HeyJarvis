//
//  CommandHistoryView.swift
//  HeyJarvisApp
//
//  Premium command history with glassmorphism cards
//

import SwiftUI

struct CommandHistoryView: View {
    let commands: [Command]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14))
                    .foregroundColor(Color("dimText"))
                
                Text("Command History")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("dimText"))
                
                Spacer()
                
                if !commands.isEmpty {
                    Text("\(commands.count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("jarvisBlue").opacity(0.5))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 4)
            
            if commands.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(commands) { command in
                            CommandCard(command: command)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.system(size: 32))
                .foregroundColor(Color("dimText").opacity(0.5))
            
            Text("No commands yet")
                .font(.system(size: 14))
                .foregroundColor(Color("dimText").opacity(0.7))
            
            Text("Say \"Hey Jarvis\" to get started")
                .font(.system(size: 12))
                .foregroundColor(Color("dimText").opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

struct CommandCard: View {
    let command: Command
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Command type icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: command.type.icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(command.text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // Type badge
                    Text(command.type.displayName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(iconColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(iconBackgroundColor)
                        .cornerRadius(4)
                    
                    // Timestamp
                    Text(command.formattedTime)
                        .font(.system(size: 11))
                        .foregroundColor(Color("dimText"))
                }
            }
            
            Spacer()
            
            // Status indicator
            statusIcon
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("accentDark"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(statusBorderColor, lineWidth: 1)
                )
        )
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
    
    private var iconBackgroundColor: Color {
        switch command.type {
        case .takePhoto:
            return Color.blue.opacity(0.2)
        case .showVideo:
            return Color.purple.opacity(0.2)
        case .recordNote:
            return Color.orange.opacity(0.2)
        case .getTime, .getDate:
            return Color.cyan.opacity(0.2)
        case .getWeather:
            return Color.yellow.opacity(0.2)
        case .setBrightness, .setVolume:
            return Color.gray.opacity(0.2)
        case .playMusic:
            return Color.pink.opacity(0.2)
        case .sendMessage:
            return Color.green.opacity(0.2)
        case .setReminder:
            return Color.red.opacity(0.2)
        case .setTimer:
            return Color.indigo.opacity(0.2)
        case .unknown:
            return Color("jarvisBlue").opacity(0.2)
        }
    }
    
    private var iconColor: Color {
        switch command.type {
        case .takePhoto:
            return Color.blue
        case .showVideo:
            return Color.purple
        case .recordNote:
            return Color.orange
        case .getTime, .getDate:
            return Color.cyan
        case .getWeather:
            return Color.yellow
        case .setBrightness, .setVolume:
            return Color.gray
        case .playMusic:
            return Color.pink
        case .sendMessage:
            return Color.green
        case .setReminder:
            return Color.red
        case .setTimer:
            return Color.indigo
        case .unknown:
            return Color("jarvisBlue")
        }
    }
    
    private var statusBorderColor: Color {
        switch command.status {
        case .success:
            return Color("successGreen").opacity(0.3)
        case .failed:
            return Color.red.opacity(0.3)
        case .pending:
            return Color.white.opacity(0.1)
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch command.status {
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color("successGreen"))
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.red)
        case .pending:
            ProgressView()
                .scaleEffect(0.8)
                .tint(Color("jarvisBlue"))
        }
    }
}

#Preview {
    ZStack {
        Color("primaryDark").ignoresSafeArea()
        CommandHistoryView(commands: [
            Command(text: "Take a photo", type: .takePhoto),
            Command(text: "What time is it?", type: .unknown),
            Command(text: "Show last video", type: .showVideo)
        ])
        .padding()
    }
}
