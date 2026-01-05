//
//  CommandReferenceView.swift
//  HeyJarvisApp
//
//  Displays a list of all available voice commands grouped by category
//

import SwiftUI

struct CommandReferenceView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("primaryDark").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Available Commands")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        // General
                        CommandCategorySection(
                            title: "General",
                            icon: "brain.head.profile",
                            commands: [
                                "Hey Jarvis",
                                "What time is it?",
                                "What's the date?",
                                "How's the weather?",
                                "Take a photo",
                                "Record a video"
                            ]
                        )
                        
                        // Productivity
                        CommandCategorySection(
                            title: "Productivity",
                            icon: "checklist",
                            commands: [
                                "Daily briefing",
                                "Good morning",
                                "Set a timer for 5 minutes",
                                "Remind me to buy milk",
                                "What's on my calendar?",
                                "Creating a note"
                            ]
                        )
                        
                        // Smart Home
                        CommandCategorySection(
                            title: "Smart Home",
                            icon: "lightbulb.fill",
                            commands: [
                                "Turn on the lights",
                                "Turn off the lights",
                                "Activate movie mode",
                                "Are the lights on?"
                            ]
                        )
                        
                        // Media
                        CommandCategorySection(
                            title: "Media",
                            icon: "play.circle.fill",
                            commands: [
                                "Play some music",
                                "Open Spotify",
                                "Next song",
                                "Pause music",
                                "Set volume to 50%"
                            ]
                        )
                        
                        // Fitness
                        CommandCategorySection(
                            title: "Fitness",
                            icon: "figure.run",
                            commands: [
                                "How many steps today?",
                                "What's my heart rate?",
                                "Open Nike Run Club",
                                "Open Strava"
                            ]
                        )
                        
                        // Navigation
                        CommandCategorySection(
                            title: "Navigation",
                            icon: "location.fill",
                            commands: [
                                "Navigate to home",
                                "Take me to Starbucks",
                                "Call an Uber"
                            ]
                        )
                        
                        // Apps
                        CommandCategorySection(
                            title: "Apps",
                            icon: "square.grid.2x2.fill",
                            commands: [
                                "Open WhatsApp",
                                "Open YouTube",
                                "Open Netflix",
                                "Open Instagram",
                                "Open Settings"
                            ]
                        )
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct CommandCategorySection: View {
    let title: String
    let icon: String
    let commands: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color("jarvisBlue"))
                    .font(.system(size: 18))
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("jarvisBlue"))
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 1) {
                ForEach(commands, id: \.self) { command in
                    HStack {
                        Text("•")
                            .foregroundColor(Color("dimText"))
                        Text("\"\(command)\"")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05))
                }
            }
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}
