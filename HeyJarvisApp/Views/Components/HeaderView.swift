//
//  HeaderView.swift
//  HeyJarvisApp
//
//  Top header with app title and primary navigation buttons.
//

import SwiftUI

struct HeaderView: View {
    @Binding var showHistory: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("HEY JARVIS")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Meta Glasses Companion")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("dimText"))
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button {
                    SoundManager.shared.playClick()
                    showHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 20))
                        .foregroundColor(Color("jarvisBlue"))
                }
                
                Button {
                    SoundManager.shared.playClick()
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color("jarvisBlue"))
                }
            }
        }
        .padding(.top, 20)
    }
}
