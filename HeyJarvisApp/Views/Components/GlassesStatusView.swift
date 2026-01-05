//
//  GlassesStatusView.swift
//  HeyJarvisApp
//
//  Displays connection state and battery for Meta Glasses.
//

import SwiftUI

struct GlassesStatusView: View {
    @ObservedObject var glassesManager: MetaGlassesManager
    var isBackgroundModeEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Glasses connection indicator
            HStack(spacing: 8) {
                Image(systemName: glassesManager.isGlassesConnected ? "eyeglasses" : "eyeglasses")
                    .font(.system(size: 16))
                    .foregroundColor(glassesManager.isGlassesConnected ? Color("successGreen") : Color("dimText"))
                
                Text(glassesManager.connectionState.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(glassesManager.isGlassesConnected ? Color("successGreen") : Color("dimText"))
                
                if glassesManager.isGlassesConnected && glassesManager.batteryLevel > 0 {
                    Text("\(glassesManager.batteryLevel)%")
                        .font(.system(size: 11))
                        .foregroundColor(Color("dimText"))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
            
            // Background mode indicator
            if isBackgroundModeEnabled {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color("successGreen"))
                        .frame(width: 8, height: 8)
                    
                    Text("Always On")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("successGreen"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color("successGreen").opacity(0.2))
                .cornerRadius(15)
            }
        }
        .padding(.top, 12)
    }
}
