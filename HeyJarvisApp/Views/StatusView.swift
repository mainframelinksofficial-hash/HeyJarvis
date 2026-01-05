//
//  StatusView.swift
//  HeyJarvisApp
//
//  Premium animated orb showing app state - Iron Man JARVIS style
//

import SwiftUI

struct StatusView: View {
    let state: AppState
    @State private var pulseAnimation = false
    @State private var rotationAngle: Double = 0
    @State private var innerPulse = false
    @State private var particleOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        stateColor.opacity(0.15 - Double(index) * 0.05),
                        lineWidth: 2
                    )
                    .frame(width: 180 + CGFloat(index * 30), height: 180 + CGFloat(index * 30))
                    .scaleEffect(pulseAnimation ? 1.1 : 0.95)
                    .animation(
                        .easeInOut(duration: 1.5 + Double(index) * 0.3)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: pulseAnimation
                    )
            }
            
            // Rotating arc rings
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .trim(from: 0.0, to: 0.3)
                    .stroke(
                        stateColor.opacity(0.4),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 160 + CGFloat(index * 20), height: 160 + CGFloat(index * 20))
                    .rotationEffect(.degrees(rotationAngle + Double(index * 180)))
            }
            
            // Particle effects
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(stateColor)
                    .frame(width: 4, height: 4)
                    .offset(y: -90)
                    .rotationEffect(.degrees(Double(index) * 45 + rotationAngle * 0.5))
                    .opacity(particleOpacity)
            }
            
            // Main orb background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            stateColor.opacity(0.3),
                            stateColor.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 40,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 20)
            
            // Main orb
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            stateColor.opacity(0.9),
                            stateColor.opacity(0.6),
                            stateColor.opacity(0.3)
                        ]),
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .offset(x: -10, y: -10)
                        .blur(radius: 10)
                )
                .shadow(color: stateColor.opacity(0.6), radius: 30)
                .scaleEffect(innerPulse ? 1.05 : 0.95)
            
            // Inner core
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 30, height: 30)
                .blur(radius: 5)
            
            // State icon
            Image(systemName: stateIcon)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
        .onAppear {
            pulseAnimation = true
            innerPulse = true
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                particleOpacity = 0.8
            }
        }
        .onChange(of: state) { _, _ in
            // Reset animation on state change
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                innerPulse.toggle()
            }
        }
    }
    
    private var stateColor: Color {
        switch state {
        case .idle:
            return Color(red: 0.4, green: 0.4, blue: 0.5) // Muted gray
        case .listening:
            return Color("jarvisBlue") // Blue
        case .wakeDetected:
            return Color(red: 0.0, green: 0.8, blue: 0.6) // Teal
        case .processing:
            return Color(red: 0.6, green: 0.4, blue: 0.9) // Purple
        case .speaking:
            return Color("successGreen") // Green
        }
    }
    
    private var stateIcon: String {
        switch state {
        case .idle:
            return "moon.fill"
        case .listening:
            return "waveform"
        case .wakeDetected:
            return "ear.fill"
        case .processing:
            return "brain.head.profile"
        case .speaking:
            return "speaker.wave.3.fill"
        }
    }
}

#Preview {
    ZStack {
        Color("primaryDark").ignoresSafeArea()
        VStack(spacing: 40) {
            StatusView(state: .listening)
            Text("Listening...")
                .foregroundColor(.white)
        }
    }
}
