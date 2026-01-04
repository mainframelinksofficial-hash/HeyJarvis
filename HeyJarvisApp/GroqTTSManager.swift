//
//  GroqTTSManager.swift
//  HeyJarvisApp
//
//  Groq Text-to-Speech API integration
//

import Foundation

class GroqTTSManager {
    private let apiEndpoint = "https://api.groq.com/openai/v1/audio/speech"
    private let model = "playai-tts"
    private let voice = "Arista-PlayAI"  // English voice option
    
    private var apiKey: String? {
        // First try Groq key, then fall back to OpenAI key field for backwards compatibility
        guard let plistPath = Bundle.main.path(forResource: "JarvisVoiceSettings", ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return nil
        }
        
        // Try Groq key first
        if let groqKey = plist["GroqAPIKey"] as? String,
           !groqKey.isEmpty,
           groqKey != "gsk_your-key-here" {
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
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "input": text,
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
}
