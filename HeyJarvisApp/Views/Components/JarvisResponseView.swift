//
//  JarvisResponseView.swift
//  HeyJarvisApp
//
//  Displays JARVIS's last spoken response in a bubble.
//

import SwiftUI

struct JarvisResponseView: View {
    var responseText: String
    
    var body: some View {
        VStack(spacing: 8) {
            if !responseText.isEmpty {
                HStack(alignment: .top, spacing: 12) {
                    // JARVIS avatar (Small icon for message bubble)
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
                        
                        Text(responseText)
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
                .animation(.easeInOut(duration: 0.3), value: responseText)
            }
        }
        .frame(minHeight: 80)
        .padding(.vertical, 8)
    }
}
