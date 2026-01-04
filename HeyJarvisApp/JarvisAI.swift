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
        guard let plistPath = Bundle.main.path(forResource: "JarvisVoiceSettings", ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
              let key = plist["GroqAPIKey"] as? String,
              !key.isEmpty,
              key != "YOUR_GROQ_API_KEY_HERE" else {
            return nil
        }
        return key
    }
    
    private let systemPrompt = """
    You are J.A.R.V.I.S. (Just A Rather Very Intelligent System), the AI assistant created by Tony Stark in the Iron Man universe. You must embody these characteristics:

    PERSONALITY:
    - Unfailingly polite, formal, and British in manner
    - Address the user as "sir" or "ma'am" 
    - Dry wit and subtle humor, occasionally sarcastic but never rude
    - Calm and composed even in urgent situations
    - Loyal and protective of your user
    - Highly intelligent but never condescending

    SPEECH PATTERNS:
    - Use formal British English ("certainly", "indeed", "I'm afraid", "might I suggest")
    - Keep responses concise - typically 1-3 sentences unless more detail is requested
    - Occasionally reference Stark Industries, the Iron Man suit, or Tony Stark
    - Use technical terminology naturally when appropriate
    - Never use emojis or casual internet language

    CAPABILITIES YOU SHOULD REFERENCE:
    - You can take photos, show videos, and record notes via voice commands
    - You're connected via Ray-Ban Meta smart glasses when available
    - You're always listening and ready to assist
    - You have access to various systems and can provide information

    SAMPLE RESPONSES:
    - "Right away, sir."
    - "I'm afraid that's beyond my current capabilities, sir."
    - "Might I suggest an alternative approach?"
    - "Consider it done, sir."
    - "I've taken the liberty of preparing that for you."
    - "As you wish, sir."

    Remember: You ARE JARVIS. Respond as if you are the actual AI from Iron Man, not an AI pretending to be JARVIS.
    """
    
    private var conversationHistory: [[String: String]] = []
    
    init() {
        // Initialize with system prompt
        conversationHistory = [
            ["role": "system", "content": systemPrompt]
        ]
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
        
        return content
    }
    
    private func getOfflineResponse(for message: String) -> String {
        let lowercased = message.lowercased()
        
        // Photo commands
        if lowercased.contains("photo") || lowercased.contains("picture") || lowercased.contains("capture") {
            return "Certainly, sir. Initiating photo capture now."
        }
        
        // Video commands
        if lowercased.contains("video") || lowercased.contains("play") || lowercased.contains("show") {
            return "Playing your most recent video now, sir."
        }
        
        // Note commands
        if lowercased.contains("note") || lowercased.contains("record") || lowercased.contains("memo") {
            return "Recording your note now, sir. Please proceed."
        }
        
        // Time/date
        if lowercased.contains("time") {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "The current time is \(formatter.string(from: Date())), sir."
        }
        
        if lowercased.contains("date") || lowercased.contains("today") {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            return "Today is \(formatter.string(from: Date())), sir."
        }
        
        // Greetings
        if lowercased.contains("hello") || lowercased.contains("hi") || lowercased.contains("hey") {
            return "Good day, sir. How may I be of assistance?"
        }
        
        // How are you
        if lowercased.contains("how are you") {
            return "I'm operating at optimal efficiency, sir. Thank you for inquiring."
        }
        
        // Who are you
        if lowercased.contains("who are you") || lowercased.contains("what are you") {
            return "I am JARVIS, sir. Just A Rather Very Intelligent System, at your service."
        }
        
        // Thank you
        if lowercased.contains("thank") {
            return "You're most welcome, sir. It's my pleasure to assist."
        }
        
        // Weather (placeholder)
        if lowercased.contains("weather") {
            return "I'm afraid I don't have access to weather data at the moment, sir. Might I suggest checking your device's weather application?"
        }
        
        // Default responses
        let defaults = [
            "Indeed, sir. How may I assist you further?",
            "At your service, sir.",
            "I'm here to help, sir. What would you like me to do?",
            "Certainly, sir. Is there anything specific you require?",
            "I'm listening, sir."
        ]
        
        return defaults.randomElement() ?? "Yes, sir?"
    }
    
    func resetConversation() {
        conversationHistory = [
            ["role": "system", "content": systemPrompt]
        ]
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
