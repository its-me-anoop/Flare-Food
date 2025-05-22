//
//  StatisticsService.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftData

/// Service for calculating statistical correlations between foods and symptoms
final class StatisticsService {
    /// The data service for fetching data
    private let dataService: DataServiceProtocol
    
    /// Time window to look for symptoms after eating (in hours)
    private let maxDelayHours: Double = 48.0
    
    /// Minimum number of occurrences needed to calculate correlation
    private let minSampleSize: Int = 5
    
    /// Initializes the statistics service
    /// - Parameter dataService: The data service for database operations
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    /// Calculates correlations for all food-symptom pairs
    /// - Returns: Array of calculated correlations
    func calculateAllCorrelations() async throws -> [Correlation] {
        // Fetch all data
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate) ?? endDate
        
        let meals = try dataService.fetchMeals(from: startDate, to: endDate)
        let symptoms = try dataService.fetchSymptoms(from: startDate, to: endDate)
        let foods = try dataService.fetchAllFoods()
        
        var correlations: [Correlation] = []
        
        // For each food-symptom combination
        for food in foods {
            for symptomType in Symptom.SymptomType.allCases {
                if let correlation = calculateCorrelation(
                    for: food,
                    symptomType: symptomType,
                    meals: meals,
                    symptoms: symptoms
                ) {
                    correlations.append(correlation)
                }
            }
        }
        
        return correlations
    }
    
    /// Calculates correlation between a specific food and symptom type
    /// - Parameters:
    ///   - food: The food to analyze
    ///   - symptomType: The symptom type to analyze
    ///   - meals: All meals in the analysis period
    ///   - symptoms: All symptoms in the analysis period
    /// - Returns: Calculated correlation or nil if insufficient data
    private func calculateCorrelation(
        for food: Food,
        symptomType: Symptom.SymptomType,
        meals: [Meal],
        symptoms: [Symptom]
    ) -> Correlation? {
        // Find all occurrences of the food
        let foodOccurrences = meals.filter { meal in
            meal.foodItems.contains { $0.food?.id == food.id }
        }
        
        guard foodOccurrences.count >= minSampleSize else { return nil }
        
        // Find symptoms of the specified type
        let relevantSymptoms = symptoms.filter { $0.type == symptomType }
        
        // Calculate occurrences and delays
        var symptomOccurrences: [SymptomOccurrence] = []
        
        for meal in foodOccurrences {
            // Look for symptoms within the time window
            let windowEnd = meal.timestamp.addingTimeInterval(maxDelayHours * 3600)
            
            let followingSymptoms = relevantSymptoms.filter { symptom in
                symptom.timestamp > meal.timestamp && symptom.timestamp <= windowEnd
            }
            
            if let firstSymptom = followingSymptoms.min(by: { $0.timestamp < $1.timestamp }) {
                let delay = firstSymptom.timestamp.timeIntervalSince(meal.timestamp) / 3600 // in hours
                symptomOccurrences.append(SymptomOccurrence(
                    hadSymptom: true,
                    severity: firstSymptom.severity,
                    delayHours: delay
                ))
            } else {
                symptomOccurrences.append(SymptomOccurrence(
                    hadSymptom: false,
                    severity: 0,
                    delayHours: 0
                ))
            }
        }
        
        // Calculate statistics
        let occurrenceRate = Double(symptomOccurrences.filter { $0.hadSymptom }.count) / Double(symptomOccurrences.count)
        
        // Calculate baseline rate (symptoms without the food)
        let mealsWithoutFood = meals.filter { meal in
            !meal.foodItems.contains { $0.food?.id == food.id }
        }
        
        var baselineOccurrences = 0
        for meal in mealsWithoutFood {
            let windowEnd = meal.timestamp.addingTimeInterval(maxDelayHours * 3600)
            let hasSymptom = relevantSymptoms.contains { symptom in
                symptom.timestamp > meal.timestamp && symptom.timestamp <= windowEnd
            }
            if hasSymptom {
                baselineOccurrences += 1
            }
        }
        
        let baselineRate = mealsWithoutFood.isEmpty ? 0.0 : Double(baselineOccurrences) / Double(mealsWithoutFood.count)
        
        // Simple correlation coefficient (difference from baseline)
        let correlationCoefficient = occurrenceRate - baselineRate
        
        // Calculate p-value using binomial test approximation
        let pValue = calculatePValue(
            occurrences: symptomOccurrences.filter { $0.hadSymptom }.count,
            trials: symptomOccurrences.count,
            expectedRate: baselineRate
        )
        
        // Calculate average delay and standard deviation
        let delays = symptomOccurrences.filter { $0.hadSymptom }.map { $0.delayHours }
        let averageDelay = delays.isEmpty ? 0 : delays.reduce(0, +) / Double(delays.count)
        let delayStdDev = calculateStandardDeviation(delays)
        
        // Calculate confidence interval
        let standardError = sqrt((occurrenceRate * (1 - occurrenceRate)) / Double(symptomOccurrences.count))
        let confidenceIntervalLower = correlationCoefficient - 1.96 * standardError
        let confidenceIntervalUpper = correlationCoefficient + 1.96 * standardError
        
        return Correlation(
            food: food,
            symptomType: symptomType,
            correlationCoefficient: correlationCoefficient,
            pValue: pValue,
            sampleSize: symptomOccurrences.count,
            confidenceIntervalLower: confidenceIntervalLower,
            confidenceIntervalUpper: confidenceIntervalUpper,
            averageDelayHours: averageDelay,
            delayStandardDeviation: delayStdDev
        )
    }
    
    /// Calculates p-value using normal approximation to binomial
    /// - Parameters:
    ///   - occurrences: Number of symptom occurrences
    ///   - trials: Total number of trials
    ///   - expectedRate: Expected rate under null hypothesis
    /// - Returns: Approximate p-value
    private func calculatePValue(occurrences: Int, trials: Int, expectedRate: Double) -> Double {
        guard trials > 0 else { return 1.0 }
        
        let observedRate = Double(occurrences) / Double(trials)
        let standardError = sqrt((expectedRate * (1 - expectedRate)) / Double(trials))
        
        guard standardError > 0 else { return 1.0 }
        
        let zScore = abs(observedRate - expectedRate) / standardError
        
        // Simple approximation of two-tailed p-value
        return 2 * (1 - normalCDF(zScore))
    }
    
    /// Normal cumulative distribution function approximation
    /// - Parameter z: Z-score
    /// - Returns: Cumulative probability
    private func normalCDF(_ z: Double) -> Double {
        // Simple approximation using error function
        return 0.5 * (1 + erf(z / sqrt(2)))
    }
    
    /// Error function approximation
    /// - Parameter x: Input value
    /// - Returns: Error function result
    private func erf(_ x: Double) -> Double {
        // Abramowitz and Stegun approximation
        let a1 =  0.254829592
        let a2 = -0.284496736
        let a3 =  1.421413741
        let a4 = -1.453152027
        let a5 =  1.061405429
        let p  =  0.3275911
        
        let sign = x < 0 ? -1.0 : 1.0
        let absX = abs(x)
        
        let t = 1.0 / (1.0 + p * absX)
        let y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-absX * absX)
        
        return sign * y
    }
    
    /// Calculates standard deviation
    /// - Parameter values: Array of values
    /// - Returns: Standard deviation
    private func calculateStandardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(values.count - 1)
        
        return sqrt(variance)
    }
    
    /// Saves calculated correlations to the database
    /// - Parameter correlations: Array of correlations to save
    func saveCorrelations(_ correlations: [Correlation]) async throws {
        for correlation in correlations {
            try dataService.saveCorrelation(correlation)
        }
    }
}

// MARK: - Supporting Types

/// Represents a symptom occurrence after eating a food
private struct SymptomOccurrence {
    let hadSymptom: Bool
    let severity: Double
    let delayHours: Double
}