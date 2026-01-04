//
//  WidgetDataManager.swift
//  HeyJarvisApp
//
//  Shares data with widgets via App Groups
//

import Foundation
import WidgetKit

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let sharedDefaults = UserDefaults(suiteName: "group.com.AI.Jarvis")
    
    private init() {}
    
    // MARK: - Update Widget Data
    
    func updateListeningState(_ isListening: Bool) {
        sharedDefaults?.set(isListening, forKey: "isListening")
        refreshWidget()
    }
    
    func updateLastCommand(_ command: String) {
        sharedDefaults?.set(command, forKey: "lastCommand")
        incrementCommandCount()
        refreshWidget()
    }
    
    func incrementCommandCount() {
        let current = sharedDefaults?.integer(forKey: "commandCount") ?? 0
        sharedDefaults?.set(current + 1, forKey: "commandCount")
    }
    
    func resetDailyCommandCount() {
        let lastReset = sharedDefaults?.object(forKey: "lastResetDate") as? Date
        let calendar = Calendar.current
        
        if let lastReset = lastReset {
            if !calendar.isDateInToday(lastReset) {
                sharedDefaults?.set(0, forKey: "commandCount")
                sharedDefaults?.set(Date(), forKey: "lastResetDate")
            }
        } else {
            sharedDefaults?.set(Date(), forKey: "lastResetDate")
        }
    }
    
    // MARK: - Check Pending Query from Shortcuts
    
    func getPendingQuery() -> String? {
        let query = sharedDefaults?.string(forKey: "pendingQuery")
        if query != nil {
            sharedDefaults?.removeObject(forKey: "pendingQuery")
        }
        return query
    }
    
    // MARK: - Refresh Widget
    
    func refreshWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
