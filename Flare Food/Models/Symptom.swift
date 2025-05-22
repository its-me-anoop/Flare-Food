//
//  Symptom.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftData
import SwiftUI

/// Represents a symptom entry tracked by the user
@Model
final class Symptom {
    /// Unique identifier for the symptom entry
    var id: UUID
    
    /// Timestamp when the symptom occurred
    var timestamp: Date
    
    /// Type of symptom
    var symptomType: String
    
    /// Severity of the symptom (0.0 to 10.0)
    var severity: Double
    
    /// Optional notes about the symptom
    var notes: String?
    
    /// Medications taken for this symptom
    var medications: [String]
    
    /// Duration of the symptom in minutes
    var durationMinutes: Int?
    
    /// Body location affected (if applicable)
    var bodyLocation: String?
    
    /// Initializes a new Symptom entry
    /// - Parameters:
    ///   - type: The type of symptom
    ///   - severity: Severity on a scale of 0-10
    ///   - notes: Optional notes
    ///   - medications: Array of medications taken
    ///   - durationMinutes: Optional duration in minutes
    ///   - bodyLocation: Optional body location
    init(
        type: SymptomType,
        severity: Double,
        notes: String? = nil,
        medications: [String] = [],
        durationMinutes: Int? = nil,
        bodyLocation: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.symptomType = type.rawValue
        self.severity = max(0.0, min(10.0, severity))
        self.notes = notes
        self.medications = medications
        self.durationMinutes = durationMinutes
        self.bodyLocation = bodyLocation
    }
}

// MARK: - Symptom Types and Categories
extension Symptom {
    /// Categories of symptoms
    enum SymptomCategory: String, CaseIterable {
        case digestive = "Digestive"
        case skin = "Skin"
        case neurological = "Neurological"
        case respiratory = "Respiratory"
        case musculoskeletal = "Musculoskeletal"
        case other = "Other"
        
        /// Icon for each category
        var icon: String {
            switch self {
            case .digestive: return "stomach"
            case .skin: return "hand.raised.fill"
            case .neurological: return "brain.head.profile"
            case .respiratory: return "lungs.fill"
            case .musculoskeletal: return "figure.walk"
            case .other: return "exclamationmark.triangle.fill"
            }
        }
        
        /// Color for each category
        var color: Color {
            switch self {
            case .digestive: return .orange
            case .skin: return .pink
            case .neurological: return .purple
            case .respiratory: return .blue
            case .musculoskeletal: return .red
            case .other: return .gray
            }
        }
    }
    
    /// Specific symptom types
    enum SymptomType: String, CaseIterable {
        // Digestive
        case bloating = "Bloating"
        case gasAndFlatulence = "Gas/Flatulence"
        case stomachPain = "Stomach Pain"
        case nausea = "Nausea"
        case diarrhea = "Diarrhea"
        case constipation = "Constipation"
        case heartburn = "Heartburn"
        case indigestion = "Indigestion"
        
        // Skin
        case rash = "Rash"
        case hives = "Hives"
        case eczemaFlare = "Eczema Flare"
        case acne = "Acne"
        case itching = "Itching"
        case dryness = "Dryness"
        
        // Neurological
        case headache = "Headache"
        case migraine = "Migraine"
        case brainFog = "Brain Fog"
        case dizziness = "Dizziness"
        case fatigue = "Fatigue"
        case insomnia = "Insomnia"
        
        // Respiratory
        case congestion = "Congestion"
        case coughing = "Coughing"
        case shortnessOfBreath = "Shortness of Breath"
        case wheezing = "Wheezing"
        
        // Musculoskeletal
        case jointPain = "Joint Pain"
        case muscleAches = "Muscle Aches"
        case stiffness = "Stiffness"
        case inflammation = "Inflammation"
        
        // Other
        case moodChanges = "Mood Changes"
        case anxiety = "Anxiety"
        case other = "Other"
        
        /// The category this symptom belongs to
        var category: SymptomCategory {
            switch self {
            case .bloating, .gasAndFlatulence, .stomachPain, .nausea, 
                 .diarrhea, .constipation, .heartburn, .indigestion:
                return .digestive
            case .rash, .hives, .eczemaFlare, .acne, .itching, .dryness:
                return .skin
            case .headache, .migraine, .brainFog, .dizziness, .fatigue, .insomnia:
                return .neurological
            case .congestion, .coughing, .shortnessOfBreath, .wheezing:
                return .respiratory
            case .jointPain, .muscleAches, .stiffness, .inflammation:
                return .musculoskeletal
            case .moodChanges, .anxiety, .other:
                return .other
            }
        }
        
        /// Icon for each symptom type
        var icon: String {
            switch self {
            // Digestive
            case .bloating: return "wind"
            case .gasAndFlatulence: return "cloud.fill"
            case .stomachPain: return "bolt.heart.fill"
            case .nausea: return "face.dashed"
            case .diarrhea: return "drop.fill"
            case .constipation: return "hourglass.bottomhalf.filled"
            case .heartburn: return "flame.fill"
            case .indigestion: return "fork.knife.circle"
            
            // Skin
            case .rash: return "allergens"
            case .hives: return "circle.hexagongrid.circle.fill"
            case .eczemaFlare: return "bandage.fill"
            case .acne: return "face.dashed.fill"
            case .itching: return "hand.raised.fingers.spread.fill"
            case .dryness: return "drop.degreesign.slash.fill"
            
            // Neurological
            case .headache: return "brain.head.profile"
            case .migraine: return "bolt.fill"
            case .brainFog: return "cloud.fog.fill"
            case .dizziness: return "tornado"
            case .fatigue: return "battery.25"
            case .insomnia: return "moon.zzz.fill"
            
            // Respiratory
            case .congestion: return "nose"
            case .coughing: return "waveform.path.ecg"
            case .shortnessOfBreath: return "lungs.fill"
            case .wheezing: return "waveform"
            
            // Musculoskeletal
            case .jointPain: return "figure.walk.motion"
            case .muscleAches: return "figure.strengthtraining.traditional"
            case .stiffness: return "figure.stand"
            case .inflammation: return "flame.circle.fill"
            
            // Other
            case .moodChanges: return "brain"
            case .anxiety: return "heart.text.square.fill"
            case .other: return "questionmark.circle.fill"
            }
        }
    }
    
    /// Computed property to get SymptomType enum from stored string
    var type: SymptomType {
        SymptomType(rawValue: symptomType) ?? .other
    }
    
    /// Severity level based on score
    var severityLevel: SeverityLevel {
        switch severity {
        case 0..<2.5: return .mild
        case 2.5..<5.0: return .moderate
        case 5.0..<7.5: return .severe
        default: return .verySevere
        }
    }
    
    /// Severity levels
    enum SeverityLevel: String {
        case mild = "Mild"
        case moderate = "Moderate"
        case severe = "Severe"
        case verySevere = "Very Severe"
        
        var color: Color {
            switch self {
            case .mild: return .green
            case .moderate: return .yellow
            case .severe: return .orange
            case .verySevere: return .red
            }
        }
    }
}