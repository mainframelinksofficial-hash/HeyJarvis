//
//  JarvisMindView.swift
//  HeyJarvisApp
//
//  "The Mind"
//  A dynamic, reactive visualization replacing the static avatar.
//  Simulates an Arc Reactor / Neural Core.
//

import SwiftUI

struct JarvisMindView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    // Animation States
    @State private var isRotating = false
    @State private var isBreathing = false
    @State private var isListening = false
    
    var body: some View {
        ZStack {
            // Core Glow
            Circle()
                .fill(Color("jarvisBlue").opacity(0.2))
                .frame(width: 80, height: 80)
                .blur(radius: 20)
                .scaleEffect(isBreathing ? 1.1 : 0.9)
            
            // Outer Ring (Static)
            Circle()
                .stroke(Color("jarvisBlue").opacity(0.3), lineWidth: 2)
                .frame(width: 100, height: 100)
            
            // Rotating Data Segments
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color("jarvisBlue"), .clear]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Color("jarvisBlue"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(Angle(degrees: isRotating ? -360 : 0))
            }
            
            // Inner Core (State dependent)
            Circle()
                .fill(coreColor)
                .frame(width: 40, height: 40)
                .shadow(color: coreColor, radius: 10)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                )
                .scaleEffect(isListening ? 1.2 : 1.0)
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: viewModel.appState) { _, newState in
            updateAnimations(for: newState)
        }
    }
    
    private var coreColor: Color {
        switch viewModel.appState {
        case .listening: return Color("neonGreen") // Listening active
        case .processing: return Color.purple // Processing thought
        case .speaking: return Color("jarvisBlue") // Speaking
        case .idle: return Color("jarvisBlue").opacity(0.8) // Standby
        }
    }
    
    private var iconName: String {
        switch viewModel.appState {
        case .listening: return "mic.fill"
        case .processing: return "cpu"
        case .speaking: return "waveform"
        case .idle: return "power"
        }
    }
    
    // MARK: - Animation Logic
    
    private func startAnimations() {
        // Idle breathing
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            isBreathing = true
        }
        
        // Idle rotation (slow)
        withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: false)) {
            isRotating = true
        }
    }
    
    private func updateAnimations(for state: AppState) {
        switch state {
        case .listening:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isListening = true
            }
        case .processing:
            // Speed up rotation? (Requires restructuring `isRotating` to use a Speed modifier, keeping simple for now)
            isListening = false
        case .speaking, .idle:
            withAnimation(.spring()) {
                isListening = false
            }
        }
    }
}

#Preview {
    JarvisMindView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
        .padding()
        .background(Color.black)
}
