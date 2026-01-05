//
//  JarvisWidget.swift
//  JarvisWidget
//
//  Home Screen Widget for JARVIS status
//

import WidgetKit
import SwiftUI

import AppIntents

// MARK: - App Intents

@available(iOS 16.0, *)
struct ToggleLightsIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Lights"
    static var description = IntentDescription("Toggles the main lights in the room.")
    
    @Parameter(title: "On")
    var isOn: Bool
    
    init() {
        self.isOn = false
    }
    
    init(isOn: Bool) {
        self.isOn = isOn
    }
    
    func perform() async throws -> some IntentResult {
        // Toggle the state in UserDefaults
        let defaults = UserDefaults(suiteName: "group.com.AI.Jarvis")
        let current = defaults?.bool(forKey: "lightsAreOn") ?? false
        let newState = !current
        defaults?.set(newState, forKey: "lightsAreOn")
        
        // In a real app, this would use HomeKit or send a network request.
        // Since we are in an extension, we update shared state.
        
        return .result()
    }
}

// MARK: - Widget Entry
struct JarvisEntry: TimelineEntry {
    let date: Date
    let isListening: Bool
    let lastCommand: String
    let commandCount: Int
    let lightsOn: Bool
}

// MARK: - Widget Provider
struct JarvisProvider: TimelineProvider {
    func placeholder(in context: Context) -> JarvisEntry {
        JarvisEntry(
            date: Date(),
            isListening: true,
            lastCommand: "Ready",
            commandCount: 0,
            lightsOn: false
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (JarvisEntry) -> Void) {
        let entry = JarvisEntry(
            date: Date(),
            isListening: UserDefaults(suiteName: "group.com.AI.Jarvis")?.bool(forKey: "isListening") ?? false,
            lastCommand: UserDefaults(suiteName: "group.com.AI.Jarvis")?.string(forKey: "lastCommand") ?? "Say 'Hey Jarvis'",
            commandCount: UserDefaults(suiteName: "group.com.AI.Jarvis")?.integer(forKey: "commandCount") ?? 0,
            lightsOn: UserDefaults(suiteName: "group.com.AI.Jarvis")?.bool(forKey: "lightsAreOn") ?? false
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<JarvisEntry>) -> Void) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.AI.Jarvis")
        
        let entry = JarvisEntry(
            date: Date(),
            isListening: sharedDefaults?.bool(forKey: "isListening") ?? false,
            lastCommand: sharedDefaults?.string(forKey: "lastCommand") ?? "Say 'Hey Jarvis'",
            commandCount: sharedDefaults?.integer(forKey: "commandCount") ?? 0,
            lightsOn: sharedDefaults?.bool(forKey: "lightsAreOn") ?? false
        )
        
        // Refresh every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Small Widget View
struct JarvisWidgetSmallView: View {
    let entry: JarvisEntry
    
    var body: some View {
        Link(destination: URL(string: "heyjarvis://listen")!) {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.18, blue: 0.22), Color(red: 0.08, green: 0.14, blue: 0.28)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(spacing: 8) {
                    // Status orb
                    ZStack {
                        Circle()
                            .fill(entry.isListening ? Color.cyan : Color.gray.opacity(0.5))
                            .frame(width: 44, height: 44)
                            .shadow(color: entry.isListening ? Color.cyan.opacity(0.6) : Color.clear, radius: 10)
                        
                        Image(systemName: entry.isListening ? "waveform" : "mic.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    Text("JARVIS")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(entry.isListening ? "Listening" : "Tap to Speak")
                        .font(.system(size: 10))
                        .foregroundColor(entry.isListening ? Color.cyan : Color.gray)
                }
            }
        }
    }
}

// MARK: - Medium Widget View
struct JarvisWidgetMediumView: View {
    let entry: JarvisEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.18, blue: 0.22), Color(red: 0.08, green: 0.14, blue: 0.28)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 16) {
                // Left side - Link to App
                Link(destination: URL(string: "heyjarvis://listen")!) {
                    ZStack {
                        Circle()
                            .fill(entry.isListening ? Color.cyan : Color.gray.opacity(0.5))
                            .frame(width: 60, height: 60)
                            .shadow(color: entry.isListening ? Color.cyan.opacity(0.6) : Color.clear, radius: 15)
                        
                        Image(systemName: entry.isListening ? "waveform" : "mic.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                
                // Right side - Controls
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("JARVIS PRO")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Interactive Button (iOS 17+)
                        if #available(iOS 17.0, *) {
                            Button(intent: ToggleLightsIntent(isOn: entry.lightsOn)) {
                                Image(systemName: entry.lightsOn ? "lightbulb.fill" : "lightbulb")
                                    .font(.system(size: 14))
                                    .foregroundColor(entry.lightsOn ? .yellow : .gray)
                                    .padding(6)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        } else {
                            Image(systemName: entry.lightsOn ? "lightbulb.fill" : "lightbulb")
                                .font(.system(size: 14))
                                .foregroundColor(entry.lightsOn ? .yellow : .gray)
                        }
                    }
                    
                    Text(entry.isListening ? "Systems Online" : "Systems Offline")
                        .font(.system(size: 12))
                        .foregroundColor(entry.isListening ? Color.cyan : Color.gray)
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.vertical, 2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 10))
                            .foregroundColor(Color.cyan.opacity(0.8))
                        
                        Text(entry.lastCommand)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                .padding(.trailing, 4)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Widget Definition
struct JarvisWidget: Widget {
    let kind: String = "JarvisWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JarvisProvider()) { entry in
            JarvisWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("JARVIS Interface")
        .description("Interactive control center")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Entry View
struct JarvisWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: JarvisEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            JarvisWidgetSmallView(entry: entry)
        case .systemMedium:
            JarvisWidgetMediumView(entry: entry)
        default:
            JarvisWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle
@main
struct JarvisWidgetBundle: WidgetBundle {
    var body: some Widget {
        JarvisWidget()
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    JarvisWidget()
} timeline: {
    JarvisEntry(date: .now, isListening: true, lastCommand: "Take a photo", commandCount: 5, lightsOn: false)
    JarvisEntry(date: .now, isListening: false, lastCommand: "Offline", commandCount: 0, lightsOn: true)
}

#Preview(as: .systemMedium) {
    JarvisWidget()
} timeline: {
    JarvisEntry(date: .now, isListening: true, lastCommand: "What time is it?", commandCount: 12, lightsOn: true)
}
