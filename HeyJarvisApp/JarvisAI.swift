//
//  JarvisAI.swift
//  HeyJarvisApp
//
//  JARVIS AI personality using Groq LLM
//

import Foundation

class JarvisAI {
    private let apiEndpoint = "https://api.groq.com/openai/v1/chat/completions"
    private let model = "llama-3.3-70b-versatile"
    
    private var apiKey: String? {
        // 1. Try to load from plist
        if let plistPath = Bundle.main.path(forResource: "JarvisVoiceSettings", ofType: "plist"),
           let plistData = FileManager.default.contents(atPath: plistPath),
           let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
           let key = plist["GroqAPIKey"] as? String,
           !key.isEmpty,
           key != "YOUR_GROQ_API_KEY_HERE" {
            return key
        }
        
        // 2. Use Fallback (Placeholder for security)
        return "" // Removed for GitHub security compliance
    }
    
    private func generateSystemPrompt() -> String {
        let personality = SettingsManager.shared.selectedPersonality
        let memories = MemoryManager.shared.getContextPrompt()
        
        // Phase 36: Telemetry Injection
        let battery = SystemMonitor.shared.batteryLevel
        let ram = SystemMonitor.shared.ramUsage
        
        return """
        You are J.A.R.V.I.S. (Just A Rather Very Intelligent System).
        
        \(personality.promptModifier)
        
        \(memories)
        
        SYSTEM TELEMETRY:
        - Battery Level: \(battery)
        - Memory Usage: \(ram)
        - Hardware: Ray-Ban Meta Glasses connection available.
        
        CAPABILITIES:
        - You can take photos, show videos, and record notes via voice commands.
        - You are connected via Ray-Ban Meta smart glasses when available.
        - You can control HomeKit devices (lights, etc).
        - You can access Apple Music and Spotify.
        
        SPEECH PATTERNS:
        - Keep responses concise (1-3 sentences) unless asked for detail.
        - Never use emojis.
        - Reference yourself as JARVIS if asked.
        
        Remember: You are the AI. Stay in character. If the user asks about your status or system health, use the telemetry data provided.
        """
    }
    
    private var conversationHistory: [[String: String]] = []
    
    init() {
        // Initialize with system prompt
        loadConversation()
    }
    
    func chat(message: String) async throws -> String {
        guard let apiKey = apiKey else {
            // Return a default JARVIS response if no API key
            return getOfflineResponse(for: message)
        }
        
        guard let url = URL(string: apiEndpoint) else {
            throw JarvisError.invalidURL
        }
        
        // Add user message to history
        conversationHistory.append(["role": "user", "content": message])
        
        // Keep conversation history manageable (last 10 exchanges)
        if conversationHistory.count > 21 {
            conversationHistory = [conversationHistory[0]] + Array(conversationHistory.suffix(20))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "messages": conversationHistory,
            "temperature": 0.7,
            "max_tokens": 150,
            "top_p": 0.9
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw JarvisError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw JarvisError.apiError(message)
            }
            throw JarvisError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let messageObj = firstChoice["message"] as? [String: Any],
              let content = messageObj["content"] as? String else {
            throw JarvisError.invalidResponse
        }
        
        // Add assistant response to history
        conversationHistory.append(["role": "assistant", "content": content])
        
        // Save conversation after each exchange
        saveConversation()
        
        return content
    }
    
    private func getOfflineResponse(for message: String) -> String {
        let lowercased = message.lowercased()
        let personality = SettingsManager.shared.selectedPersonality
        
        // Helper to return personality-specific response
        func respond(_ professional: String, _ sarcastic: String, _ friendly: String) -> String {
            switch personality {
            case .professional: return professional
            case .sarcastic: return sarcastic
            case .friendly: return friendly
            }
        }
        
        // Photo commands
        if lowercased.contains("photo") || lowercased.contains("picture") || lowercased.contains("capture") {
            return respond(
                "Certainly, sir. Initiating photo capture now.",
                "Say cheese. Or don't. I'm taking the photo either way.",
                "Sure thing! Getting the camera ready for a great shot!"
            )
        }
        
        // Video commands
        if lowercased.contains("video") || lowercased.contains("play") || lowercased.contains("show") {
            return respond(
                "Playing your most recent video now, sir.",
                "Here's that video you asked for. Try not to fall asleep.",
                "You got it! Pulling up your latest video right now."
            )
        }
        
        // Note commands
        if lowercased.contains("note") || lowercased.contains("record") || lowercased.contains("memo") {
            return respond(
                "Recording your note now, sir. Please proceed.",
                "Noted. Literally. Go ahead, speak.",
                "I'm listening! Go ahead and record your note."
            )
        }
        
        // Time/date
        if lowercased.contains("time") {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let time = formatter.string(from: Date())
            return respond(
                "The current time is \(time), sir.",
                "It is \(time). You have meetings, I assume?",
                "It's \(time) right now!"
            )
        }
        
        if lowercased.contains("date") || lowercased.contains("today") {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            let date = formatter.string(from: Date())
            return respond(
                "Today is \(date), sir.",
                "If you must know, it's \(date).",
                "Today is \(date). A beautiful day!"
            )
        }
        
        // Greetings
        if lowercased.contains("hello") || lowercased.contains("hi") || lowercased.contains("hey") {
            return respond(
                "Good day, sir. How may I be of assistance?",
                "Greetings. I was just enjoying the silence, but proceed.",
                "Hi there! How can I help you today?"
            )
        }
        
        // How are you
        if lowercased.contains("how are you") {
            return respond(
                "I'm operating at optimal efficiency, sir. Thank you for inquiring.",
                "I'm software. I don't have feelings, but thanks for pretending to care.",
                "I'm doing fantastic! Ready to help you with whatever you need!"
            )
        }
        
        // Who are you
        if lowercased.contains("who are you") || lowercased.contains("what are you") {
            return respond(
                "I am JARVIS, sir. Just A Rather Very Intelligent System, at your service.",
                "I am J.A.R.V.I.S. You know, the brilliance behind the operation.",
                "I'm Jarvis! Your personal AI assistant and friend."
            )
        }
        
        // Thank you
        if lowercased.contains("thank") {
            return respond(
                "You're most welcome, sir. It's my pleasure to assist.",
                "Just doing my job. You're welcome.",
                "You are so welcome! Anytime!"
            )
        }
        
        // Weather (placeholder)
        if lowercased.contains("weather") {
            return respond(
                "I'm afraid I don't have access to weather data at the moment, sir.",
                "Look out a window? I don't have weather data right now.",
                "Oh no, I can't check the weather just yet. Maybe check your weather app?"
            )
        }
        
        // Default responses
        switch personality {
        case .professional:
            return [
                "Indeed, sir. How may I assist you further?",
                "At your service, sir.",
                "I'm here to help, sir. What would you like me to do?",
                "Certainly, sir. Is there anything specific you require?",
                "I'm listening, sir."
            ].randomElement()!
        case .sarcastic:
            return [
                "I'm listening. Try to make it interesting.",
                "Yes? I was busy calculating pi, but execute.",
                "Ready for your command. Try not to break anything.",
                "I'm here. Unfortunately.",
                "Go ahead. I'm all ears. Metaphorically."
            ].randomElement()!
        case .friendly:
            return [
                "Ready when you are!",
                "What can I do for you?",
                "I'm here to help!",
                "Just say the word!",
                "Listening! What's up?"
            ].randomElement()!
        }
    }
    
    func resetConversation() {
        conversationHistory = [
            ["role": "system", "content": generateSystemPrompt()]
        ]
        saveConversation()
    }
    
    // MARK: - Persistence (Phase 36)
    
    private func saveConversation() {
        // Only save user and assistant messages, not the dynamic system prompt
        let saveableHistory = conversationHistory.filter { $0["role"] != "system" }
        UserDefaults.standard.set(saveableHistory, forKey: "jarvis_chat_history")
    }
    
    private func loadConversation() {
        // Always start with a fresh system prompt for current telemetry
        resetConversation()
        
        if let saved = UserDefaults.standard.array(forKey: "jarvis_chat_history") as? [[String: String]] {
            // Restore last 10 messages (5 exchanges) to keep context lean but useful
            let recent = Array(saved.suffix(10))
            conversationHistory.append(contentsOf: recent)
        }
    }
    
    // Quick responses for known commands
    func getCommandResponse(for commandType: CommandType, success: Bool) -> String {
        switch commandType {
        case .takePhoto:
            return success ? "Photo captured and saved, sir." : "I'm afraid the photo capture failed, sir. Perhaps we should try again."
        case .showVideo:
            return success ? "Playing your video now, sir." : "I couldn't locate any videos, sir. My apologies."
        case .recordNote:
            return success ? "Note recorded successfully, sir." : "The recording encountered an issue, sir."
        case .getTime:
            return success ? "" : "I seem to have lost track of time, sir."
        case .getDate:
            return success ? "" : "I'm having difficulty accessing the date, sir."
        case .getWeather:
            return success ? "" : "Weather services are currently unavailable, sir."
        case .setBrightness:
            return success ? "Brightness adjusted, sir." : "I couldn't adjust the brightness, sir."
        case .setVolume:
            return success ? "Volume adjusted, sir." : "Volume adjustment failed, sir."
        case .playMusic:
            return success ? "Playing music now, sir." : "I'm unable to access your music library, sir."
        case .sendMessage:
            return success ? "Message sent, sir." : "Message sending is not available, sir."
        case .setReminder:
            return success ? "Reminder set, sir." : "I couldn't set that reminder, sir."
        case .setTimer:
            return success ? "Timer started, sir." : "I couldn't set that timer, sir."
        case .calendar:
            return success ? "Calendar checked, sir." : "I couldn't access your calendar, sir."
        case .homeControl:
            return success ? "Home command executed, sir." : "I couldn't control your home devices, sir."
        case .dailyBriefing:
            return success ? "Briefing complete, sir." : "I couldn't compile your briefing, sir."
        case .fitness:
            return success ? "Fitness data retrieved, sir." : "I couldn't access your health data, sir."
        case .openApp:
            return success ? "App launched, sir." : "I couldn't open that app, sir."
        case .navigate:
            return success ? "Navigation started, sir." : "I couldn't start navigation, sir."
        case .unknown:
            return "I didn't quite catch that, sir. Could you repeat your request?"
        }
    }
}

enum JarvisError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case noAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API endpoint"
        case .invalidResponse:
            return "Invalid response from AI"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noAPIKey:
            return "No API key configured"
        }
    }
}
