//
//  CommandManager.swift
//  HeyJarvisApp
//
//  Text-to-command parsing
//

import Foundation

class CommandManager {
    
    private let photoKeywords = ["take a photo", "take photo", "capture photo", "snap a photo", "take a picture", "take picture"]
    private let videoKeywords = ["show last video", "play video", "show video", "play last video", "show the video"]
    private let noteKeywords = ["record note", "save note", "record a note", "take a note", "make a note", "record voice note"]
    
    func parseCommand(_ text: String) -> CommandType {
        let normalizedText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        for keyword in photoKeywords {
            if normalizedText.contains(keyword) {
                return .takePhoto
            }
        }
        
        for keyword in videoKeywords {
            if normalizedText.contains(keyword) {
                return .showVideo
            }
        }
        
        for keyword in noteKeywords {
            if normalizedText.contains(keyword) {
                return .recordNote
            }
        }
        
        if normalizedText.contains("photo") || normalizedText.contains("picture") {
            return .takePhoto
        }
        
        if normalizedText.contains("video") {
            return .showVideo
        }
        
        if normalizedText.contains("note") || normalizedText.contains("record") {
            return .recordNote
        }
        
        return .unknown
    }
}
