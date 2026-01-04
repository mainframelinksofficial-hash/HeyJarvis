//
//  WatchSessionManager.swift
//  HeyJarvisApp
//
//  Manages communication between iPhone and Apple Watch
//

import Foundation
import WatchConnectivity
import Combine

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    
    @Published var isWatchReachable = false
    @Published var lastMessage: String = ""
    
    // Command handler closure
    var onCommandReceived: ((String) -> Void)?
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendStatusToWatch(isListening: Bool, statusText: String) {
        guard WCSession.default.isReachable else { return }
        
        let message: [String: Any] = [
            "isListening": isListening,
            "status": statusText,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending to watch: \(error.localizedDescription)")
        }
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Required for implementation
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Reactivate session
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let command = message["command"] as? String {
                self.lastMessage = command
                self.onCommandReceived?(command)
                
                // Vibrate to confirm receipt
                if settings.hapticFeedbackEnabled {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }
        }
    }
    
    private var settings: SettingsManager {
        return SettingsManager.shared
    }
}
