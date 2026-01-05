//
//  AppLauncherManager.swift
//  HeyJarvisApp
//
//  Opens third-party apps using URL schemes
//
//  HOW IT WORKS:
//  1. User says "Open Uber" or "Call me a ride"
//  2. We use iOS URL schemes to launch apps directly
//  3. No SDK needed - just URL schemes!
//

import UIKit
import Foundation

class AppLauncherManager: ObservableObject {
    static let shared = AppLauncherManager()
    
    private init() {}
    
    // MARK: - App Definitions
    
    struct AppInfo {
        let name: String
        let urlScheme: String
        let keywords: [String]
    }
    
    private let supportedApps: [AppInfo] = [
        // Ride Sharing
        AppInfo(name: "Uber", urlScheme: "uber://", keywords: ["uber", "ride", "car"]),
        AppInfo(name: "Lyft", urlScheme: "lyft://", keywords: ["lyft"]),
        
        // Navigation
        AppInfo(name: "Maps", urlScheme: "maps://", keywords: ["maps", "navigate", "directions"]),
        AppInfo(name: "Waze", urlScheme: "waze://", keywords: ["waze"]),
        AppInfo(name: "Google Maps", urlScheme: "comgooglemaps://", keywords: ["google maps"]),
        
        // Messaging
        AppInfo(name: "WhatsApp", urlScheme: "whatsapp://", keywords: ["whatsapp"]),
        AppInfo(name: "Telegram", urlScheme: "tg://", keywords: ["telegram"]),
        AppInfo(name: "Signal", urlScheme: "sgnl://", keywords: ["signal"]),
        
        // Entertainment
        AppInfo(name: "YouTube", urlScheme: "youtube://", keywords: ["youtube", "video"]),
        AppInfo(name: "Netflix", urlScheme: "netflix://", keywords: ["netflix"]),
        AppInfo(name: "Disney+", urlScheme: "disneyplus://", keywords: ["disney"]),
        AppInfo(name: "Hulu", urlScheme: "hulu://", keywords: ["hulu"]),
        AppInfo(name: "Prime Video", urlScheme: "aiv://", keywords: ["prime", "amazon"]),
        AppInfo(name: "Twitch", urlScheme: "twitch://", keywords: ["twitch"]),
        
        // Social
        AppInfo(name: "Twitter", urlScheme: "twitter://", keywords: ["twitter", "x"]),
        AppInfo(name: "Instagram", urlScheme: "instagram://", keywords: ["instagram"]),
        AppInfo(name: "TikTok", urlScheme: "tiktok://", keywords: ["tiktok"]),
        AppInfo(name: "Facebook", urlScheme: "fb://", keywords: ["facebook"]),
        AppInfo(name: "Snapchat", urlScheme: "snapchat://", keywords: ["snapchat"]),
        AppInfo(name: "Reddit", urlScheme: "reddit://", keywords: ["reddit"]),
        
        // Productivity
        AppInfo(name: "Slack", urlScheme: "slack://", keywords: ["slack"]),
        AppInfo(name: "Discord", urlScheme: "discord://", keywords: ["discord"]),
        AppInfo(name: "Notion", urlScheme: "notion://", keywords: ["notion"]),
        AppInfo(name: "Notes", urlScheme: "mobilenotes://", keywords: ["notes", "apple notes"]),
        
        // Food
        AppInfo(name: "DoorDash", urlScheme: "doordash://", keywords: ["doordash", "food"]),
        AppInfo(name: "Uber Eats", urlScheme: "ubereats://", keywords: ["uber eats"]),
        AppInfo(name: "Grubhub", urlScheme: "grubhub://", keywords: ["grubhub"]),
        
        // Finance
        AppInfo(name: "Venmo", urlScheme: "venmo://", keywords: ["venmo", "pay"]),
        AppInfo(name: "PayPal", urlScheme: "paypal://", keywords: ["paypal"]),
        AppInfo(name: "Cash App", urlScheme: "cashme://", keywords: ["cash app"]),
        
        // Shopping
        AppInfo(name: "Amazon", urlScheme: "amazon://", keywords: ["amazon", "shop"]),
        AppInfo(name: "eBay", urlScheme: "ebay://", keywords: ["ebay"]),
        
        // Fitness & Health (User requested!)
        AppInfo(name: "Nike Run Club", urlScheme: "nikerunclub://", keywords: ["nike", "run", "running", "jog"]),
        AppInfo(name: "Apple Fitness", urlScheme: "fitness://", keywords: ["fitness app", "apple fitness"]),
        AppInfo(name: "Health", urlScheme: "x-apple-health://", keywords: ["health app", "apple health"]),
        AppInfo(name: "Strava", urlScheme: "strava://", keywords: ["strava", "cycling"]),
        AppInfo(name: "Peloton", urlScheme: "pelotoncycle://", keywords: ["peloton"]),
        AppInfo(name: "MyFitnessPal", urlScheme: "myfitnesspal://", keywords: ["myfitnesspal", "calories"]),
    ]
    
    // MARK: - Launch App
    
    func launchApp(from text: String) -> String {
        let lowercased = text.lowercased()
        
        // Find matching app
        for app in supportedApps {
            for keyword in app.keywords {
                if lowercased.contains(keyword) {
                    return openApp(app)
                }
            }
        }
        
        return "I couldn't identify which app you'd like to open, sir. Try saying 'Open YouTube' or 'Launch Uber'."
    }
    
    private func openApp(_ app: AppInfo) -> String {
        guard let url = URL(string: app.urlScheme) else {
            return "I couldn't create the URL for \(app.name), sir."
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return "Opening \(app.name), sir."
        } else {
            return "\(app.name) doesn't appear to be installed, sir."
        }
    }
    
    // MARK: - Navigation
    
    func navigateTo(destination: String) -> String {
        let encoded = destination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? destination
        
        // Use Apple Maps
        guard let url = URL(string: "maps://?daddr=\(encoded)") else {
            return "I couldn't create the navigation URL, sir."
        }
        
        UIApplication.shared.open(url)
        return "Opening Maps with directions to \(destination), sir."
    }
    
    func searchMaps(query: String) -> String {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        guard let url = URL(string: "maps://?q=\(encoded)") else {
            return "I couldn't create the search URL, sir."
        }
        
        UIApplication.shared.open(url)
        return "Searching Maps for \(query), sir."
    }
    
    // MARK: - Ride Sharing
    
    func callRide() -> String {
        // Try Uber first, then Lyft
        if let uberURL = URL(string: "uber://"), UIApplication.shared.canOpenURL(uberURL) {
            UIApplication.shared.open(uberURL)
            return "Opening Uber to request a ride, sir."
        } else if let lyftURL = URL(string: "lyft://"), UIApplication.shared.canOpenURL(lyftURL) {
            UIApplication.shared.open(lyftURL)
            return "Opening Lyft to request a ride, sir."
        } else {
            return "Neither Uber nor Lyft appear to be installed, sir."
        }
    }
    
    // MARK: - Get Available Apps
    
    func listInstalledApps() -> String {
        var installed: [String] = []
        
        for app in supportedApps {
            if let url = URL(string: app.urlScheme), UIApplication.shared.canOpenURL(url) {
                installed.append(app.name)
            }
        }
        
        if installed.isEmpty {
            return "I couldn't detect any supported apps, sir."
        }
        
        let appList = installed.prefix(5).joined(separator: ", ")
        return "I can open apps like \(appList), and many more."
    }
}
