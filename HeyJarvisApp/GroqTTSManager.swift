//
//  GroqTTSManager.swift
//  HeyJarvisApp
//
//  Groq TTS for JARVIS voice - using playai-tts for reliability
//

import Foundation

class GroqTTSManager {
    private let apiEndpoint = "https://api.groq.com/openai/v1/audio/speech"
    private let model = "playai-tts"
    
    // Voice is now pulled from user settings
    
    private var apiKey: String? {
        guard let plistPath = Bundle.main.path(forResource: "JarvisVoiceSettings", ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            print("JARVIS TTS: Could not load plist")
            return nil
        }
        
        if let groqKey = plist["GroqAPIKey"] as? String,
           !groqKey.isEmpty,
           groqKey != "YOUR_GROQ_API_KEY_HERE" {
            print("JARVIS TTS: API key found")
            return groqKey
        }
        
        print("JARVIS TTS: No valid API key")
        return nil
    }
    
    func synthesize(text: String) async throws -> Data {
        guard let apiKey = apiKey else {
            print("JARVIS TTS: Throwing noAPIKey error")
            throw TTSError.noAPIKey
        }
        
        guard let url = URL(string: apiEndpoint) else {
            throw TTSError.invalidURL
        }
        
        // Limit text length for API
        let processedText = String(text.prefix(500))
        
        print("JARVIS TTS: Synthesizing: \(processedText)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        // Get voice from user settings
        let selectedVoice = SettingsManager.shared.selectedVoice.rawValue
        print("JARVIS TTS: Using voice: \(selectedVoice)")
        
        let body: [String: Any] = [
            "model": model,
            "input": processedText,
            "voice": selectedVoice,
            "response_format": "mp3"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("JARVIS TTS: Sending request to \(apiEndpoint)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("JARVIS TTS: Invalid response type")
            throw TTSError.invalidResponse
        }
        
        print("JARVIS TTS: Response status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("JARVIS TTS: Error response: \(errorString)")
            }
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw TTSError.apiError(message)
            }
            throw TTSError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        print("JARVIS TTS: Received \(data.count) bytes of audio")
        return data
    }
}
