//
//  OpenAITTSManager.swift
//  HeyJarvisApp
//
//  OpenAI Text-to-Speech API integration
//

import Foundation

class OpenAITTSManager {
    private let apiEndpoint = "https://api.openai.com/v1/audio/speech"
    private let model = "gpt-4o-mini-tts"
    private let voice = "onyx"
    
    private var apiKey: String? {
        guard let plistPath = Bundle.main.path(forResource: "JarvisVoiceSettings", ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
              let key = plist["OpenAIAPIKey"] as? String,
              !key.isEmpty,
              key != "sk-your-key-here" else {
            return nil
        }
        return key
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
            "response_format": "mp3"
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

enum TTSError: LocalizedError {
    case noAPIKey
    case invalidURL
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No OpenAI API key configured"
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}
