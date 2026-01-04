//
//  GroqTTSManager.swift
//  HeyJarvisApp
//
//  Groq Orpheus TTS with vocal directions for expressive JARVIS voice
//

import Foundation

class GroqTTSManager {
    private let apiEndpoint = "https://api.groq.com/openai/v1/audio/speech"
    private let model = "canopylabs/orpheus-v1-english"
    private let voice = "troy"  // Best male voice for expressive JARVIS
    
    private var apiKey: String? {
        guard let plistPath = Bundle.main.path(forResource: "JarvisVoiceSettings", ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return nil
        }
        
        if let groqKey = plist["GroqAPIKey"] as? String,
           !groqKey.isEmpty,
           groqKey != "YOUR_GROQ_API_KEY_HERE" {
            return groqKey
        }
        
        return nil
    }
    
    func synthesize(text: String) async throws -> Data {
        guard let apiKey = apiKey else {
            throw TTSError.noAPIKey
        }
        
        guard let url = URL(string: apiEndpoint) else {
            throw TTSError.invalidURL
        }
        
        // Add JARVIS vocal directions for expressive performance
        let expressiveText = addJarvisVocalDirections(to: text)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "input": expressiveText,
            "voice": voice,
            "response_format": "wav"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TTSError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw TTSError.apiError(message)
            }
            throw TTSError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        return data
    }
    
    /// Add JARVIS-style vocal directions for expressive speech
    private func addJarvisVocalDirections(to text: String) -> String {
        let lowercased = text.lowercased()
        
        // Truncate to 200 chars max (API limit) after adding directions
        var result = text
        
        // Greetings - formal and warm
        if lowercased.contains("at your service") || lowercased.contains("good day") || lowercased.contains("good morning") {
            result = "[formal warm] " + text
        }
        // Confirmations - professionally confident  
        else if lowercased.contains("certainly") || lowercased.contains("right away") || lowercased.contains("consider it done") {
            result = "[professionally confident] " + text
        }
        // Apologies or failures - sympathetic but composed
        else if lowercased.contains("i'm afraid") || lowercased.contains("my apologies") || lowercased.contains("unfortunately") {
            result = "[sympathetically formal] " + text
        }
        // Success messages - satisfied and warm
        else if lowercased.contains("success") || lowercased.contains("captured") || lowercased.contains("recorded") || lowercased.contains("saved") {
            result = "[satisfied warmly] " + text
        }
        // Questions from JARVIS - inquisitive but polite
        else if text.contains("?") {
            result = "[politely inquisitive] " + text
        }
        // Alerts or warnings - authoritative but calm
        else if lowercased.contains("warning") || lowercased.contains("alert") || lowercased.contains("caution") {
            result = "[authoritatively calm] " + text
        }
        // Wit or humor - dry deadpan
        else if lowercased.contains("might i suggest") || lowercased.contains("perhaps") || lowercased.contains("if i may") {
            result = "[dry wit] " + text
        }
        // System status - professionally composed
        else if lowercased.contains("online") || lowercased.contains("systems") || lowercased.contains("operational") {
            result = "[professionally composed] " + text
        }
        // Default - formal British butler style
        else {
            result = "[formally reserved] " + text
        }
        
        // Ensure we don't exceed 200 character limit
        if result.count > 200 {
            // Remove direction and truncate text instead
            let maxTextLength = 200 - 25 // Leave room for direction
            let truncatedText = String(text.prefix(maxTextLength))
            result = "[formally] " + truncatedText
        }
        
        return result
    }
}
