//
//  HealthManager.swift
//  HeyJarvisApp
//
//  Manages HealthKit data access for fitness stats
//
//  HOW IT WORKS:
//  1. Request authorization to read health data
//  2. Query HealthKit for steps, heart rate, sleep, etc.
//  3. Format into natural language for JARVIS
//

import HealthKit
import Foundation

class HealthManager: ObservableObject {
    static let shared = HealthManager()
    
    private let healthStore = HKHealthStore()
    private var isAuthorized = false
    
    private init() {}
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        // Types we want to read
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKCategoryType(.sleepAnalysis)
        ]
        
        // Types we want to share (write)
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceCycling)
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            isAuthorized = true
            return true
        } catch {
            print("HealthKit authorization failed: \(error)")
            return false
        }
    }
    
    // MARK: - Step Count
    
    func getTodaySteps() async -> String {
        guard await requestAuthorization() else {
            return "I need permission to access your health data, sir."
        }
        
        let stepsType = HKQuantityType(.stepCount)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        do {
            let steps = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    let sum = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    continuation.resume(returning: sum)
                }
                healthStore.execute(query)
            }
            
            let stepsInt = Int(steps)
            if stepsInt == 0 {
                return "You haven't recorded any steps today, sir. Time to get moving!"
            } else if stepsInt < 5000 {
                return "You've taken \(stepsInt.formatted()) steps today, sir. Keep going!"
            } else if stepsInt < 10000 {
                return "You've taken \(stepsInt.formatted()) steps today, sir. Well on your way to your goal!"
            } else {
                return "Impressive! You've taken \(stepsInt.formatted()) steps today, sir. Excellent work!"
            }
        } catch {
            return "I couldn't retrieve your step data, sir."
        }
    }
    
    // MARK: - Heart Rate
    
    func getLatestHeartRate() async -> String {
        guard await requestAuthorization() else {
            return "I need permission to access your health data, sir."
        }
        
        let heartRateType = HKQuantityType(.heartRate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        do {
            let heartRate = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    if let sample = samples?.first as? HKQuantitySample {
                        let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        continuation.resume(returning: bpm)
                    } else {
                        continuation.resume(returning: 0)
                    }
                }
                healthStore.execute(query)
            }
            
            if heartRate == 0 {
                return "No heart rate data available, sir. Do you have an Apple Watch?"
            }
            
            let bpm = Int(heartRate)
            if bpm < 60 {
                return "Your heart rate is \(bpm) BPM, sir. Nice and relaxed."
            } else if bpm < 100 {
                return "Your heart rate is \(bpm) BPM, sir. Looking normal."
            } else {
                return "Your heart rate is \(bpm) BPM, sir. Elevated - have you been active?"
            }
        } catch {
            return "I couldn't retrieve your heart rate data, sir."
        }
    }
    
    // MARK: - Activity Summary
    
    func getActivitySummary() async -> String {
        let steps = await getTodaySteps()
        // Could add more data here
        return steps
    }
}
