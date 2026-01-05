//
//  TTSError.swift
//  HeyJarvisApp
//
//  Text-to-Speech error types
//

import Foundation

enum TTSError: LocalizedError {
    case noAPIKey
    case invalidURL
    case invalidResponse
    case apiError(String)
    case audioPlaybackFailed
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key configured. Add your Groq API key to JarvisVoiceSettings.plist"
        case .invalidURL:
            return "Invalid API endpoint URL"
        case .invalidResponse:
            return "Invalid response from TTS API"
        case .apiError(let message):
            return "API Error: \(message)"
        case .audioPlaybackFailed:
            return "Failed to play audio"
        }
    }
}
