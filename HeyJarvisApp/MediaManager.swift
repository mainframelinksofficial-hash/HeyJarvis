//
//  MediaManager.swift
//  HeyJarvisApp
//
//  Manages System Music Player (Apple Music)
//

import MediaPlayer
import Foundation

class MediaManager: ObservableObject {
    static let shared = MediaManager()
    
    private let player = MPMusicPlayerController.systemMusicPlayer
    
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
    
    func setVolume(_ level: Float) {
        // Note: MPVolumeView is required for slider, but direct setting is deprecated/restricted.
        // We generally can't set system volume effortlessly without UI.
        // However, we can use the systemMusicPlayer volume *if* deprecated API allows, 
        // or just acknowledge limit.
        // For modern iOS, we usually just tell the user to use buttons.
        // But we can try systemMusicPlayer.volume (deprecated in 11.3) or leave it.
        // Best practice: Just advise.
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
}
