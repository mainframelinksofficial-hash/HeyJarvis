//
//  HeyJarvisApp.swift
//  HeyJarvisApp
//
//  Created for Ray-Ban Meta Glasses Companion
//  iOS 18.0+ | SwiftUI App Lifecycle
//

import SwiftUI
import UIKit

@main
struct HeyJarvisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    handleQuickAction(url: url)
                }
        }
    }
    
    private func handleQuickAction(url: URL) {
        guard url.scheme == "jarvis" else { return }
        
        switch url.host {
        case "briefing":
            appViewModel.handleCommandReceived("good morning")
        case "lights":
            appViewModel.handleCommandReceived("turn on the lights")
        case "timer":
            appViewModel.handleCommandReceived("set a timer for 5 minutes")
        default:
            break
        }
    }
}

// MARK: - App Delegate for Quick Actions
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        // Register Quick Actions (3D Touch / Long Press shortcuts)
        let briefingAction = UIApplicationShortcutItem(
            type: "com.AI.Jarvis.briefing",
            localizedTitle: "Daily Briefing",
            localizedSubtitle: "Get your morning update",
            icon: UIApplicationShortcutIcon(systemImageName: "sun.horizon.fill"),
            userInfo: nil
        )
        
        let lightsAction = UIApplicationShortcutItem(
            type: "com.AI.Jarvis.lights",
            localizedTitle: "Lights On",
            localizedSubtitle: "Turn on HomeKit lights",
            icon: UIApplicationShortcutIcon(systemImageName: "lightbulb.fill"),
            userInfo: nil
        )
        
        let timerAction = UIApplicationShortcutItem(
            type: "com.AI.Jarvis.timer",
            localizedTitle: "Quick Timer",
            localizedSubtitle: "5 minute timer",
            icon: UIApplicationShortcutIcon(systemImageName: "timer"),
            userInfo: nil
        )
        
        let askAction = UIApplicationShortcutItem(
            type: "com.AI.Jarvis.ask",
            localizedTitle: "Ask JARVIS",
            localizedSubtitle: "Start listening",
            icon: UIApplicationShortcutIcon(systemImageName: "waveform"),
            userInfo: nil
        )
        
        application.shortcutItems = [briefingAction, lightsAction, timerAction, askAction]
        
        return UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcut(shortcutItem)
        completionHandler(true)
    }
    
    private func handleShortcut(_ item: UIApplicationShortcutItem) {
        var command = ""
        
        switch item.type {
        case "com.AI.Jarvis.briefing":
            command = "good morning"
        case "com.AI.Jarvis.lights":
            command = "turn on the lights"
        case "com.AI.Jarvis.timer":
            command = "set a timer for 5 minutes"
        case "com.AI.Jarvis.ask":
            command = "listen"
        default:
            return
        }
        
        // Post notification to trigger command
        NotificationCenter.default.post(
            name: NSNotification.Name("QuickActionCommand"),
            object: command
        )
    }
}
