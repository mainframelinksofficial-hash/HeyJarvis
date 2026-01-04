//
//  MediaManager.swift
//  HeyJarvisApp
//
//  Manages System Music Player (Apple Music)
//

import MediaPlayer
import Foundation
import UIKit

class MediaManager: ObservableObject {
    static let shared = MediaManager()
    
    private let player = MPMusicPlayerController.systemMusicPlayer
    
    // MARK: - Apple Music Controls
    
    func playMusic() -> String {
        if player.playbackState == .playing {
            return "Music is already playing, sir."
        }
        
        player.play()
        return "Resuming playback."
    }
    
    func pauseMusic() -> String {
        if player.playbackState == .paused || player.playbackState == .stopped {
            return "Playback is already paused, sir."
        }
        
        player.pause()
        return "Pausing music."
    }
    
    func skipTrack() -> String {
        player.skipToNextItem()
        return "Skipping track."
    }
    
    func previousTrack() -> String {
        player.skipToPreviousItem()
        return "Replaying previous track."
    }
    
    func getNowPlaying() -> String {
        if let item = player.nowPlayingItem {
            let title = item.title ?? "Unknown Title"
            let artist = item.artist ?? "Unknown Artist"
            return "Currently playing \(title) by \(artist)."
        }
        return "Nothing is currently playing, sir."
    }
    
    func requestAuthorization() {
        MPMediaLibrary.requestAuthorization { status in
            // Handle status
        }
    }
    
    // MARK: - Spotify Integration
    //
    // HOW IT WORKS:
    // We use URL schemes to open Spotify app directly.
    // This doesn't require Spotify SDK or developer account!
    // The Spotify app handles everything once opened.
    //
    
    /// Check if Spotify is installed
    var isSpotifyInstalled: Bool {
        return UIApplication.shared.canOpenURL(URL(string: "spotify:")!)
    }
    
    /// Open Spotify and start playing
    func openSpotify() -> String {
        guard let url = URL(string: "spotify:") else {
            return "Could not create Spotify URL."
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return "Opening Spotify, sir."
        } else {
            return "Spotify doesn't appear to be installed, sir."
        }
    }
    
    /// Search for music in Spotify
    /// Example: "Play AC/DC on Spotify"
    func searchSpotify(query: String) -> String {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "spotify:search:\(encoded)") else {
            return "Could not create search URL."
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return "Searching Spotify for \(query), sir."
        } else {
            return "Spotify doesn't appear to be installed, sir."
        }
    }
    
    /// Play a specific Spotify playlist/album/track by URI
    /// Example URI: spotify:playlist:37i9dQZF1DXcBWIGoYBM5M
    func playSpotifyURI(_ uri: String) -> String {
        guard let url = URL(string: uri) else {
            return "Invalid Spotify URI."
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return "Opening in Spotify, sir."
        } else {
            return "Spotify doesn't appear to be installed, sir."
        }
    }
}
