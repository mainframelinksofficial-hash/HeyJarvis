//
//  WorkoutManager.swift
//  HeyJarvisApp
//
//  Manages HealthKit workout sessions and live data tracking
//

import Foundation
import HealthKit
import Combine

class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    // Published metrics for UI updates
    @Published var isWorkoutActive = false
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    
    private var timer: Timer?
    private var startDate: Date?
    
    override private init() {
        super.init()
    }
    
    func startWorkout(type: HKWorkoutActivityType) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type
        configuration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            session?.delegate = self
            builder?.delegate = self
            
            session?.startActivity(with: Date())
            try await builder?.beginCollection(at: Date())
            
            await MainActor.run {
                self.isWorkoutActive = true
                self.startDate = Date()
                self.startTimer()
            }
        } catch {
            print("Failed to start workout: \(error.localizedDescription)")
            throw error
        }
    }
    
    func endWorkout() {
        session?.end()
        builder?.endCollection(withEnd: Date()) { (success, error) in
            self.builder?.finishWorkout { (workout, error) in
                DispatchQueue.main.async {
                    self.isWorkoutActive = false
                    self.stopTimer()
                    self.resetMetrics()
                    print("Workout finished and saved: \(String(describing: workout))")
                }
            }
        }
    }
    
    func pauseWorkout() {
        session?.pause()
        stopTimer()
    }
    
    func resumeWorkout() {
        session?.resume()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startDate = self.startDate else { return }
            self.elapsedTime = Date().timeIntervalSince(startDate)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetMetrics() {
        heartRate = 0
        activeEnergy = 0
        distance = 0
        elapsedTime = 0
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ session: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle state changes if needed
        DispatchQueue.main.async {
            self.isWorkoutActive = (toState == .running)
        }
    }
    
    func workoutSession(_ session: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            guard let statistics = workoutBuilder.statistics(for: quantityType) else { continue }
            
            DispatchQueue.main.async {
                switch quantityType {
                case HKQuantityType.quantityType(forIdentifier: .heartRate):
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                    
                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                    let energyUnit = HKUnit.kilocalorie()
                    self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
                    
                case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
                     HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                    let meterUnit = HKUnit.meter()
                    self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
                    
                default:
                    break
                }
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events
    }
}
