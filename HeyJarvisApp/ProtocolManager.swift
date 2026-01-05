//
//  ProtocolManager.swift
//  HeyJarvisApp
//
//  Manages custom "Protocols" (Macros) that execute multiple actions
//  triggered by a specific phrase.
//

import Foundation

struct JarvisProtocol: Codable, Identifiable {
    var id = UUID()
    let name: String
    let triggerPhrase: String
    let actions: [ProtocolAction]
    let response: String? // Optional custom response on completion
}

enum ProtocolActionType: String, Codable {
    case lights
    case volume
    case music
    case lock
    case say
    case wait
}

struct ProtocolAction: Codable, Identifiable {
    var id = UUID()
    let type: ProtocolActionType
    let value: String // "100", "Purple", "Shoot to Thrill", etc.
}

@MainActor
class ProtocolManager: ObservableObject {
    /// The shared engine for executing multi-action macro sequences.
    static let shared = ProtocolManager()
    
    /// A list of all user-defined and default protocols.
    @Published var protocols: [JarvisProtocol] = []
    
    private let defaults = UserDefaults.standard
    private let kProtocolsKey = "jarvis_custom_protocols"
    
    private init() {
        loadProtocols()
        
        // Add default "Party Mode" if empty
        if protocols.isEmpty {
            createDefaultProtocols()
        }
    }
    
    // MARK: - CRUD
    
    /// Registers a new custom protocol into the system memory.
    /// - Parameter newProtocol: The protocol configuration to add.
    func addProtocol(_ newProtocol: JarvisProtocol) {
        protocols.append(newProtocol)
        saveProtocols()
        print("ProtocolManager: Added '\(newProtocol.name)'")
    }
    
    /// Removes protocols at the specified index set.
    func removeProtocol(at indexSet: IndexSet) {
        protocols.remove(atOffsets: indexSet)
        saveProtocols()
    }
    
    /// Matches a transcribed text string against registered trigger phrases.
    /// - Parameter text: The voice transcription to check.
    /// - Returns: The most specific matching protocol, if any.
    func checkTrigger(_ text: String) -> JarvisProtocol? {
        let lower = text.lowercased()
        // Find all matches, then pick the one with the longest trigger phrase (most specific)
        let matches = protocols.filter { lower.contains($0.triggerPhrase.lowercased()) }
        return matches.sorted { $0.triggerPhrase.count > $1.triggerPhrase.count }.first
    }
    
    // MARK: - Defaults
    
    private func createDefaultProtocols() {
        let partyMode = JarvisProtocol(
            name: "House Party",
            triggerPhrase: "party mode",
            actions: [
                ProtocolAction(type: .lights, value: "purple"),
                ProtocolAction(type: .volume, value: "100"),
                ProtocolAction(type: .say, value: "Let's rock, sir.")
            ],
            response: nil
        )
        
        let goodnight = JarvisProtocol(
            name: "Goodnight",
            triggerPhrase: "goodnight protocol",
            actions: [
                ProtocolAction(type: .lights, value: "off"),
                ProtocolAction(type: .volume, value: "0"),
                ProtocolAction(type: .say, value: "Sleep well, sir. Monitoring perimeter.")
            ],
            response: nil
        )
        
        protocols = [partyMode, goodnight]
        saveProtocols()
    }
    
    // MARK: - Persistence
    
    private func saveProtocols() {
        do {
            let encoded = try JSONEncoder().encode(protocols)
            defaults.set(encoded, forKey: kProtocolsKey)
        } catch {
            print("ProtocolManager Error: Failed to save protocols - \(error.localizedDescription)")
        }
    }
    
    private func loadProtocols() {
        guard let data = defaults.data(forKey: kProtocolsKey) else { return }
        
        do {
            protocols = try JSONDecoder().decode([JarvisProtocol].self, from: data)
        } catch {
            print("ProtocolManager Error: Failed to load protocols - \(error.localizedDescription)")
        }
    }
}
