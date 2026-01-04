//
//  JarvisIntents.swift
//  HeyJarvisApp
//
//  Siri Shortcuts integration with App Intents
//

import AppIntents
import SwiftUI

// MARK: - Ask Jarvis Intent
struct AskJarvisIntent: AppIntent {
    static var title: LocalizedStringResource = "Ask Jarvis"
    static var description = IntentDescription("Ask JARVIS a question or give a command")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Question or Command")
    var query: String
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // The app will handle the query when it opens
        UserDefaults(suiteName: "group.com.AI.Jarvis")?.set(query, forKey: "pendingQuery")
        
        return .result(dialog: "Opening JARVIS...")
    }
}

// MARK: - Take Photo Intent
struct TakePhotoIntent: AppIntent {
    static var title: LocalizedStringResource = "Take Photo with Jarvis"
    static var description = IntentDescription("Ask JARVIS to take a photo")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        UserDefaults(suiteName: "group.com.AI.Jarvis")?.set("take a photo", forKey: "pendingQuery")
        
        return .result(dialog: "Opening JARVIS to take a photo...")
    }
}

// MARK: - Record Note Intent
struct RecordNoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Note with Jarvis"
    static var description = IntentDescription("Ask JARVIS to record a voice note")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        UserDefaults(suiteName: "group.com.AI.Jarvis")?.set("record a note", forKey: "pendingQuery")
        
        return .result(dialog: "Opening JARVIS to record a note...")
    }
}

// MARK: - Get Time Intent
struct GetTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "Ask Jarvis for Time"
    static var description = IntentDescription("Ask JARVIS what time it is")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: Date())
        
        return .result(dialog: "The current time is \(timeString), sir.")
    }
}

// MARK: - Shortcuts Provider
struct JarvisShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AskJarvisIntent(),
            phrases: [
                "Ask \(.applicationName) something",
                "Talk to \(.applicationName)",
                "Hey \(.applicationName)"
            ],
            shortTitle: "Ask Jarvis",
            systemImageName: "waveform"
        )
        
        AppShortcut(
            intent: TakePhotoIntent(),
            phrases: [
                "Take a photo with \(.applicationName)",
                "\(.applicationName) take a picture"
            ],
            shortTitle: "Take Photo",
            systemImageName: "camera.fill"
        )
        
        AppShortcut(
            intent: RecordNoteIntent(),
            phrases: [
                "Record a note with \(.applicationName)",
                "\(.applicationName) record note"
            ],
            shortTitle: "Record Note",
            systemImageName: "mic.fill"
        )
        
        AppShortcut(
            intent: GetTimeIntent(),
            phrases: [
                "Ask \(.applicationName) for the time",
                "\(.applicationName) what time is it"
            ],
            shortTitle: "Get Time",
            systemImageName: "clock.fill"
        )
    }
}
