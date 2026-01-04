//
//  WatchContentView.swift
//  HeyJarvisWatch
//
//  Main interface for Apple Watch
//

import SwiftUI
import WatchConnectivity
import AVFoundation

struct WatchContentView: View {
    @StateObject private var viewModel = WatchViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            // Status Indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.cyan, Color.blue]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(Angle(degrees: viewModel.isListening ? 360 : 0))
                    .frame(width: 80, height: 80)
                    .animation(viewModel.isListening ? Animation.linear(duration: 2).repeatForever(autoreverses: false) : .default, value: viewModel.isListening)
                
                Image(systemName: viewModel.isListening ? "waveform" : "mic.fill")
                    .font(.system(size: 32))
                    .foregroundColor(viewModel.isListening ? .cyan : .white)
            }
            .onTapGesture {
                viewModel.toggleListening()
            }
            
            // Status Text
            Text(viewModel.statusText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Last Command
            if !viewModel.lastCommand.isEmpty {
                Text(viewModel.lastCommand)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

class WatchViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var isListening = false
    @Published var statusText = "Tap to Listen"
    @Published var lastCommand = ""
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func toggleListening() {
        // Send command to iPhone to start/stop listening
        if WCSession.default.isReachable {
            let message = ["command": isListening ? "stop" : "listen"]
            WCSession.default.sendMessage(message, replyHandler: nil)
            
            // Optimistic update
            if !isListening {
                statusText = "Listening..."
                isListening = true
            }
        } else {
            statusText = "Phone Unreachable"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.statusText = "Tap to Listen"
            }
        }
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Activation complete
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let listening = message["isListening"] as? Bool {
                self.isListening = listening
            }
            if let status = message["status"] as? String {
                self.statusText = status
            }
        }
    }
}
