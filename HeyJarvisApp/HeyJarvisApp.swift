//
//  HeyJarvisApp.swift
//  HeyJarvisApp
//
//  Created for Ray-Ban Meta Glasses Companion
//  iOS 18.0+ | SwiftUI App Lifecycle
//

import SwiftUI

@main
struct HeyJarvisApp: App {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
