//
//  HomeManager.swift
//  HeyJarvisApp
//
//  Manages HomeKit interactions
//

import HomeKit
import Foundation

class HomeManager: NSObject, HMHomeManagerDelegate, ObservableObject {
    static let shared = HomeManager()
    
    @Published var homeManager: HMHomeManager
    @Published var isAuthorized = false
    
    override private init() {
        self.homeManager = HMHomeManager()
        super.init()
        self.homeManager.delegate = self
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        if !manager.homes.isEmpty {
            self.isAuthorized = true
        }
    }
    
    // MARK: - Actions
    
    func toggleLights(on: Bool) -> String {
        guard let home = homeManager.primaryHome else {
            return "I'm afraid I cannot access your primary residence, sir."
        }
        
        var lightsFound = 0
        
        for accessory in home.accessories {
            for service in accessory.services where service.serviceType == HMServiceTypeLightbulb {
                for characteristic in service.characteristics where characteristic.characteristicType == HMCharacteristicTypePowerState {
                    characteristic.writeValue(on) { error in
                        if let error = error {
                            print("Error setting light: \(error)")
                        }
                    }
                    lightsFound += 1
                }
            }
        }
        
        if lightsFound == 0 {
            return "No smart lights were found in your primary residence, sir."
        } else {
            return on ? "Illuminating the premises, sir." : "Killing the lights, sir."
        }
    }
    
    func checkLightStatus() -> String {
        guard let home = homeManager.primaryHome else {
            return "HomeKit data unavailable."
        }
        
        var onLights = 0
        var totalLights = 0
        
        for accessory in home.accessories {
            for service in accessory.services where service.serviceType == HMServiceTypeLightbulb {
                totalLights += 1
                for characteristic in service.characteristics where characteristic.characteristicType == HMCharacteristicTypePowerState {
                    if let value = characteristic.value as? Bool, value == true {
                        onLights += 1
                    }
                }
            }
        }
        
        if totalLights == 0 {
            return "No lights found."
        }
        
        return "\(onLights) of \(totalLights) lights are currently active."
    }
}
