//
//  CommandHistoryView.swift
//  HeyJarvisApp
//
//  "Mission Log"
//  A terminal-style stream of historical system actions.
//

import SwiftUI

struct CommandHistoryView: View {
    let commands: [Command]
    
    var body: some View {
        ZStack {
            // Background Grid (subtle tech texture)
            VStack(spacing: 0) {
                ForEach(0..<20) { _ in
                    Divider().background(Color("jarvisBlue").opacity(0.1))
                    Spacer()
                }
            }
            .opacity(0.3)
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("jarvisBlue"))
                    
                    Text("MISSION LOG // DATA STREAM")
                        .font(.custom("Courier", size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(Color("jarvisBlue"))
                        .tracking(1)
                    
                    Spacer()
                    
                    if !commands.isEmpty {
                        Text("REC: \(commands.count)")
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("jarvisBlue").opacity(0.3))
                            .cornerRadius(4)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.5))
                
                Divider().background(Color("jarvisBlue"))
                
                if commands.isEmpty {
                    emptyState
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(commands.reversed()) { command in
                                MissionLogEntry(command: command)
                                Divider().background(Color.white.opacity(0.1))
                            }
                        }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("jarvisBlue").opacity(0.5), lineWidth: 1)
                )
        )
        .padding()
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cursorarrow.rays")
                .font(.system(size: 40))
                .foregroundColor(Color("jarvisBlue").opacity(0.5))
            
            Text("DATA STREAM EMPTY")
                .font(.custom("Courier", size: 16))
                .foregroundColor(Color("dimText"))
                .tracking(2)
            
            Text("Awaiting input...")
                .font(.custom("Courier", size: 12))
                .foregroundColor(Color("dimText").opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct MissionLogEntry: View {
    let command: Command
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timestamp column
            Text(command.formattedTime)
                .font(.custom("Courier", size: 11))
                .foregroundColor(Color("jarvisBlue"))
                .frame(width: 50, alignment: .leading)
                .padding(.top, 2)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(command.text.uppercased())
                    .font(.custom("Courier", size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack {
                    Text("TYPE: \(command.type.displayName.uppercased())")
                    Spacer()
                    Text(command.status.rawValue.uppercased())
                        .foregroundColor(statusColor)
                }
                .font(.custom("Courier", size: 10))
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Status Indicator
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
                .shadow(color: statusColor, radius: 4)
                .padding(.top, 6)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.02))
    }
    
    private var statusColor: Color {
        switch command.status {
        case .success: return .green
        case .failed: return .red
        case .pending: return .orange
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CommandHistoryView(commands: [
            Command(text: "Initiate Party Mode", type: .executeProtocol, status: .success),
            Command(text: "What time is it?", type: .getTime, status: .success),
            Command(text: "Set phasers to stun", type: .unknown, status: .failed)
        ])
    }
}
