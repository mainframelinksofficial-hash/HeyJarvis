//
//  CommandHistoryView.swift
//  HeyJarvisApp
//
//  Scrollable command history list
//

import SwiftUI

struct CommandHistoryView: View {
    let commands: [Command]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !commands.isEmpty {
                Text("Command History")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("dimText"))
                    .padding(.horizontal, 4)
            }
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(commands) { command in
                        CommandRow(command: command)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct CommandRow: View {
    let command: Command
    
    private var statusColor: Color {
        switch command.status {
        case .pending:
            return Color("jarvisBlue")
        case .success:
            return Color("successGreen")
        case .failed:
            return Color.red
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: command.type.icon)
                .font(.system(size: 16))
                .foregroundColor(Color("jarvisBlue"))
                .frame(width: 36, height: 36)
                .background(Color("jarvisBlue").opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(command.text.capitalized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(command.type.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("dimText"))
                    
                    Text("•")
                        .foregroundColor(Color("dimText"))
                    
                    Text(command.formattedTime)
                        .font(.system(size: 11))
                        .foregroundColor(Color("dimText"))
                }
            }
            
            Spacer()
            
            Image(systemName: command.status.icon)
                .font(.system(size: 16))
                .foregroundColor(statusColor)
        }
        .padding(12)
        .background(Color("accentDark"))
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        Color("primaryDark").ignoresSafeArea()
        
        CommandHistoryView(commands: [
            Command(text: "Take a photo", type: .takePhoto, status: .success),
            Command(text: "Show last video", type: .showVideo, status: .pending),
            Command(text: "Record note", type: .recordNote, status: .failed)
        ])
        .padding()
    }
}
