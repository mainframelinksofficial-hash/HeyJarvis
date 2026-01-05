//
//  MemoryManager.swift
//  HeyJarvisApp
//
//  Manages persistent "memories" or facts about the user
//  to provide a personalized AI experience.
//

import Foundation

struct UserFact: Codable, Identifiable {
    var id = UUID()
    let content: String
    let dateAdded: Date
}

class MemoryManager: ObservableObject {
    static let shared = MemoryManager()
    
    @Published var facts: [UserFact] = []
    
    private let defaults = UserDefaults.standard
    private let kFactsKey = "jarvis_user_facts"
    
    private init() {
        loadFacts()
    }
    
    // MARK: - CRUD Operations
    
    func addFact(_ content: String) {
        let cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanContent.isEmpty else { return }
        
        let newFact = UserFact(content: cleanContent, dateAdded: Date())
        facts.append(newFact)
        saveFacts()
        print("JARVIS Memory: Added fact - \(cleanContent)")
    }
    
    func removeFact(at indexSet: IndexSet) {
        facts.remove(atOffsets: indexSet)
        saveFacts()
    }
    
    func clearAllMemories() {
        facts.removeAll()
        saveFacts()
    }
    
    func getContextPrompt() -> String {
        guard !facts.isEmpty else { return "" }
        
        let factsList = facts.map { "- \($0.content)" }.joined(separator: "\n")
        return """
        
        [USER MEMORIES]
        You know the following facts about the user. Use them to personalize your responses:
        \(factsList)
        """
        return """
        
        [USER MEMORIES]
        You know the following facts about the user. Use them to personalize your responses:
        \(factsList)
        """
    }
    
    func getRandomMemory() -> String? {
        return facts.randomElement()?.content
    }
    
    // MARK: - Persistence
    
    private func saveFacts() {
        if let encoded = try? JSONEncoder().encode(facts) {
            defaults.set(encoded, forKey: kFactsKey)
        }
    }
    
    private func loadFacts() {
        if let data = defaults.data(forKey: kFactsKey),
           let decoded = try? JSONDecoder().decode([UserFact].self, from: data) {
            facts = decoded
        }
    }
}
