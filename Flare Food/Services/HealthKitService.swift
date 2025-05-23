//
//  HealthKitService.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import Foundation
import HealthKit

/// Service for managing HealthKit integration
class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    // HealthKit types we want to write
    private let caffeineType = HKQuantityType(.dietaryCaffeine)
    private let waterType = HKQuantityType(.dietaryWater)
    
    init() {
        checkAuthorization()
    }
    
    /// Check if HealthKit is available
    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    /// Request HealthKit authorization
    func requestAuthorization() async -> Bool {
        guard isHealthKitAvailable else { return false }
        
        let typesToWrite: Set<HKSampleType> = [caffeineType, waterType]
        let typesToRead: Set<HKObjectType> = [caffeineType, waterType]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            await MainActor.run {
                self.checkAuthorization()
            }
            return true
        } catch {
            print("HealthKit authorization failed: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    private func checkAuthorization() {
        guard isHealthKitAvailable else {
            isAuthorized = false
            return
        }
        
        let caffeineAuth = healthStore.authorizationStatus(for: caffeineType)
        let waterAuth = healthStore.authorizationStatus(for: waterType)
        
        isAuthorized = caffeineAuth == .sharingAuthorized && waterAuth == .sharingAuthorized
    }
    
    /// Save caffeine intake to HealthKit
    func saveCaffeineIntake(amount: Double, date: Date) async -> Bool {
        guard isAuthorized else { return false }
        
        let quantity = HKQuantity(unit: .gramUnit(with: .milli), doubleValue: amount)
        let sample = HKQuantitySample(
            type: caffeineType,
            quantity: quantity,
            start: date,
            end: date
        )
        
        do {
            try await healthStore.save(sample)
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastHealthKitSync)
            return true
        } catch {
            print("Failed to save caffeine intake: \(error)")
            return false
        }
    }
    
    /// Save water intake to HealthKit
    func saveWaterIntake(amount: Double, date: Date) async -> Bool {
        guard isAuthorized else { return false }
        
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: amount)
        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: date,
            end: date
        )
        
        do {
            try await healthStore.save(sample)
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastHealthKitSync)
            return true
        } catch {
            print("Failed to save water intake: \(error)")
            return false
        }
    }
    
    /// Sync fluid entry to HealthKit
    func syncFluidEntry(_ entry: FluidEntry) async {
        // Save water intake
        await saveWaterIntake(amount: entry.amount, date: entry.timestamp)
        
        // Save caffeine if present
        if let caffeineAmount = entry.caffeineContent, caffeineAmount > 0 {
            await saveCaffeineIntake(amount: caffeineAmount, date: entry.timestamp)
        }
    }
    
    /// Get total caffeine for a date range
    func getCaffeineIntake(from startDate: Date, to endDate: Date) async -> Double? {
        guard isAuthorized else { return nil }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: caffeineType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                guard let result = result,
                      let sum = result.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let value = sum.doubleValue(for: .gramUnit(with: .milli))
                continuation.resume(returning: value)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Get total water intake for a date range
    func getWaterIntake(from startDate: Date, to endDate: Date) async -> Double? {
        guard isAuthorized else { return nil }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: waterType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                guard let result = result,
                      let sum = result.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let value = sum.doubleValue(for: .literUnit(with: .milli))
                continuation.resume(returning: value)
            }
            
            healthStore.execute(query)
        }
    }
}