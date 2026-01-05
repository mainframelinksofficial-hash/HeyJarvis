//
//  CommandReferenceView.swift
//  HeyJarvisApp
//
//  "Command Database // Holographic Index"
//  A futuristic catalog of all available system commands.
//

import SwiftUI

struct CommandReferenceView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    // Grid columns
    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Tech overlay
            VStack {
                Divider().background(Color("jarvisBlue").opacity(0.3))
                Spacer()
            }
            .padding(.top, 50)
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("COMMAND DATABASE")
                                .font(.custom("Courier", size: 12))
                                .foregroundColor(Color("jarvisBlue"))
                                .tracking(2)
                            
                            Text("INDEX // VER 3.1")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color("jarvisBlue"))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Search Bar (Visual only for now)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("jarvisBlue"))
                        TextField("SEARCH INDEX...", text: $searchText)
                            .font(.custom("Courier", size: 14))
                            .foregroundColor(.white)
                            .accentColor(Color("jarvisBlue"))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("jarvisBlue").opacity(0.5), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    // Grid Layout
                    LazyVGrid(columns: columns, spacing: 16) {
                        // General
                        CommandCardSection(
                            title: "GENERAL",
                            icon: "brain.head.profile",
                            commands: [
                                "Hey Jarvis",
                                "What time is it?",
                                "Take a photo"
                            ]
                        )
                        
                        // Productivity
                        CommandCardSection(
                            title: "PRODUCTIVITY",
                            icon: "checklist",
                            commands: [
                                "Daily briefing",
                                "Set timer for...",
                                "Remind me to..."
                            ]
                        )
                        
                        // Smart Home
                        CommandCardSection(
                            title: "SMART HOME",
                            icon: "lightbulb.fill",
                            commands: [
                                "Lights on/off",
                                "Turn on lights",
                                "Party mode"
                            ]
                        )
                        
                        // Media
                        CommandCardSection(
                            title: "MEDIA",
                            icon: "play.circle.fill",
                            commands: [
                                "Play music",
                                "Volume 50%",
                                "Next song"
                            ]
                        )
                        
                        // Fitness
                        CommandCardSection(
                            title: "FITNESS",
                            icon: "figure.run",
                            commands: [
                                "Step count",
                                "Heart rate",
                                "Health status"
                            ]
                        )
                        
                        // Custom Protocols
                        CommandCardSection(
                            title: "PROTOCOLS",
                            icon: "bolt.shield.fill",
                            commands: [
                                "Party Mode",
                                "Goodnight Protocol",
                                "Security check"
                            ]
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct CommandCardSection: View {
    let title: String
    let icon: String
    let commands: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color("jarvisBlue"))
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color("jarvisBlue"))
                    .tracking(1)
            }
            
            Divider().background(Color("jarvisBlue").opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(commands, id: \.self) { cmd in
                    HStack(spacing: 6) {
                        Text("•")
                            .foregroundColor(Color("dimText"))
                            .font(.system(size: 10))
                        Text(cmd)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        // Make cards equal height in the grid
        .frame(minHeight: 160, alignment: .top)
    }
}

#Preview {
    CommandReferenceView()
}
