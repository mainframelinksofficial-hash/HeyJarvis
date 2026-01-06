//
//  WorkoutManager.swift
//  HeyJarvisApp
//
//  SIMULATION MODE - Manages fake workout sessions for testing
//

import Foundation
import HealthKit
import Combine

class WorkoutManager: ObservableObject {
    static let shared = WorkoutManager()
    
    // Published metrics for UI updates
    @Published var isWorkoutActive = false
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    
    private var timer: Timer?
    private var startDate: Date?
    private var currentType: HKWorkoutActivityType = .running
    
    private init() {}
    
    func startWorkout(type: HKWorkoutActivityType) async throws {
        // No actual HealthKit session is started to avoid permission/entitlement crashes
        self.currentType = type
        
        await MainActor.run {
            self.isWorkoutActive = true
            self.startDate = Date()
            self.startSimulationTimer()
            print("SIMULATION: Started workout of type \(type.rawValue)")
        }
    }
    
    func endWorkout() {
        stopSimulationTimer()
        
        DispatchQueue.main.async {
            self.isWorkoutActive = false
            self.resetMetrics()
            print("SIMULATION: Ended workout")
        }
    }
    
    func pauseWorkout() {
        stopSimulationTimer()
    }
    
    func resumeWorkout() {
        startSimulationTimer()
    }
    
    private func startSimulationTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startDate = self.startDate else { return }
            
            // Update time
            self.elapsedTime = Date().timeIntervalSince(startDate)
            
            // Simulate Metrics
            self.simulateHeartRate()
            self.simulateCalories()
            self.simulateDistance()
        }
    }
    
    private func stopSimulationTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetMetrics() {
        heartRate = 0
        activeEnergy = 0
        distance = 0
        elapsedTime = 0
    }
    
    // MARK: - Simulation Logic
    
    private func simulateHeartRate() {
        // Random variance between 90 and 150 bpm
        let variance = Double.random(in: -2...2)
        let baseHeartRate: Double = 110
        let newHeartRate = baseHeartRate + variance
        self.heartRate = newHeartRate
    }
    
    private func simulateCalories() {
        // Approx 10 calories per minute (0.16 per second)
        self.activeEnergy += 0.16
    }
    
    private func simulateDistance() {
        // Approx 3 meters per second (running speed)
        // Adjust based on type if needed
        var speed: Double = 0
        switch currentType {
        case .running: speed = 3.0
        case .walking: speed = 1.4
        case .cycling: speed = 7.0
        default: speed = 0.5
        }
        
        self.distance += speed
    }
}
