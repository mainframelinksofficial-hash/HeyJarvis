//
//  TranscriptionView.swift
//  HeyJarvisApp
//
//  Displays real-time speech transcription.
//

import SwiftUI

struct TranscriptionView: View {
    var text: String
    
    var body: some View {
        VStack(spacing: 8) {
            if !text.isEmpty {
                Text("Heard:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("dimText"))
                
                Text(text)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
            }
        }
        .frame(height: 50)
    }
}
