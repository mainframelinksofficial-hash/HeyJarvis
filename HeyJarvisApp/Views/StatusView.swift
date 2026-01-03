//
//  StatusView.swift
//  HeyJarvisApp
//
//  Animated status orb visualization
//

import SwiftUI

struct StatusView: View {
    let state: AppState
    
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    
    private var orbColor: Color {
        switch state {
        case .idle:
            return Color("dimText")
        case .listening:
            return Color("jarvisBlue")
        case .wakeDetected:
            return Color("successGreen")
        case .processing:
            return Color.orange
        case .speaking:
            return Color("jarvisBlue")
        }
    }
    
    private var glowColor: Color {
        orbColor.opacity(0.5)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(glowColor)
                    .frame(width: 180, height: 180)
                    .blur(radius: 40)
                    .opacity(glowOpacity)
                    .scaleEffect(pulseScale)
                
                Circle()
                    .fill(glowColor)
                    .frame(width: 140, height: 140)
                    .blur(radius: 25)
                    .opacity(glowOpacity * 0.8)
                    .scaleEffect(pulseScale * 0.9)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [orbColor, orbColor.opacity(0.6)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: orbColor.opacity(0.5), radius: 20, x: 0, y: 5)
                
                if state == .processing {
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                }
            }
            .onAppear {
                startAnimations()
            }
            .onChange(of: state) { _, _ in
                startAnimations()
            }
            
            Text(state.statusText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch state {
            case .idle:
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.05
                    glowOpacity = 0.2
                }
                
            case .listening:
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.2
                    glowOpacity = 0.5
                }
                
            case .wakeDetected:
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    pulseScale = 1.4
                    glowOpacity = 0.8
                }
                withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                    pulseScale = 1.1
                    glowOpacity = 0.6
                }
                
            case .processing:
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulseScale = 1.15
                    glowOpacity = 0.4
                }
                
            case .speaking:
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    pulseScale = 1.1
                    glowOpacity = 0.6
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color("primaryDark").ignoresSafeArea()
        VStack(spacing: 40) {
            StatusView(state: .idle)
            StatusView(state: .listening)
            StatusView(state: .processing)
        }
    }
}
