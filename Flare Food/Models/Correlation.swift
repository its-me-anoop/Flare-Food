//
//  Correlation.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftData

/// Represents a statistical correlation between a food and a symptom
@Model
final class Correlation {
    /// Unique identifier
    var id: UUID
    
    /// The food involved in this correlation
    var food: Food?
    
    /// The symptom type correlated with the food
    var symptomType: String
    
    /// Correlation coefficient (-1.0 to 1.0)
    /// Positive values indicate food increases symptom likelihood
    /// Negative values indicate food decreases symptom likelihood
    var correlationCoefficient: Double
    
    /// Statistical significance (p-value)
    var pValue: Double
    
    /// Number of data points used to calculate this correlation
    var sampleSize: Int
    
    /// Confidence interval lower bound
    var confidenceIntervalLower: Double
    
    /// Confidence interval upper bound
    var confidenceIntervalUpper: Double
    
    /// Date when this correlation was last calculated
    var lastCalculated: Date
    
    /// Average time delay between food consumption and symptom onset (in hours)
    var averageDelayHours: Double
    
    /// Standard deviation of delay times
    var delayStandardDeviation: Double
    
    /// Initializes a new Correlation
    /// - Parameters:
    ///   - food: The food item
    ///   - symptomType: The symptom type
    ///   - correlationCoefficient: The correlation coefficient
    ///   - pValue: Statistical significance
    ///   - sampleSize: Number of data points
    ///   - confidenceIntervalLower: Lower bound of confidence interval
    ///   - confidenceIntervalUpper: Upper bound of confidence interval
    ///   - averageDelayHours: Average delay between consumption and symptom
    ///   - delayStandardDeviation: Standard deviation of delays
    init(
        food: Food,
        symptomType: Symptom.SymptomType,
        correlationCoefficient: Double,
        pValue: Double,
        sampleSize: Int,
        confidenceIntervalLower: Double,
        confidenceIntervalUpper: Double,
        averageDelayHours: Double = 0,
        delayStandardDeviation: Double = 0
    ) {
        self.id = UUID()
        self.food = food
        self.symptomType = symptomType.rawValue
        self.correlationCoefficient = correlationCoefficient
        self.pValue = pValue
        self.sampleSize = sampleSize
        self.confidenceIntervalLower = confidenceIntervalLower
        self.confidenceIntervalUpper = confidenceIntervalUpper
        self.lastCalculated = Date()
        self.averageDelayHours = averageDelayHours
        self.delayStandardDeviation = delayStandardDeviation
    }
}

// MARK: - Correlation Analysis
extension Correlation {
    /// Strength of the correlation
    var strength: CorrelationStrength {
        let absValue = abs(correlationCoefficient)
        switch absValue {
        case 0..<0.3: return .weak
        case 0.3..<0.7: return .moderate
        default: return .strong
        }
    }
    
    /// Whether this correlation is statistically significant
    var isSignificant: Bool {
        pValue < 0.05
    }
    
    /// Direction of the correlation
    var direction: CorrelationDirection {
        if correlationCoefficient > 0 {
            return .positive
        } else if correlationCoefficient < 0 {
            return .negative
        } else {
            return .none
        }
    }
    
    /// Correlation strength categories
    enum CorrelationStrength: String {
        case weak = "Weak"
        case moderate = "Moderate"
        case strong = "Strong"
    }
    
    /// Correlation direction
    enum CorrelationDirection: String {
        case positive = "Positive"
        case negative = "Negative"
        case none = "None"
        
        var description: String {
            switch self {
            case .positive:
                return "Increases likelihood"
            case .negative:
                return "Decreases likelihood"
            case .none:
                return "No correlation"
            }
        }
    }
    
    /// Formatted description of the correlation
    var formattedDescription: String {
        let strengthText = strength.rawValue.lowercased()
        let directionText = direction == .positive ? "increases" : "decreases"
        let symptom = Symptom.SymptomType(rawValue: symptomType)?.rawValue ?? symptomType
        
        if isSignificant {
            return "This food \(strengthText) \(directionText) the likelihood of \(symptom.lowercased())"
        } else {
            return "No significant correlation found with \(symptom.lowercased())"
        }
    }
}