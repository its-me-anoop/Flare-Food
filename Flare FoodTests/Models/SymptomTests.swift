//
//  SymptomTests.swift
//  Flare FoodTests
//
//  Created by Anoop Jose on 22/05/2025.
//

import Testing
import SwiftData
@testable import Flare_Food

/// Tests for the Symptom model
struct SymptomTests {
    
    @Test("Symptom initialization with default values")
    func testSymptomInitializationDefaults() async throws {
        // Given
        let profileId = UUID()
        let type = Symptom.SymptomType.headache
        let severity = 7.5
        
        // When
        let symptom = Symptom(profileId: profileId, type: type, severity: severity)
        
        // Then
        #expect(symptom.profileId == profileId)
        #expect(symptom.symptomType == type.rawValue)
        #expect(symptom.severity == severity)
        #expect(symptom.notes == nil)
        #expect(symptom.medications.isEmpty)
        #expect(symptom.durationMinutes == nil)
        #expect(symptom.bodyLocation == nil)
        #expect(symptom.timestamp.timeIntervalSinceNow < 1)
    }
    
    @Test("Symptom initialization with all parameters")
    func testSymptomInitializationWithAllParameters() async throws {
        // Given
        let profileId = UUID()
        let type = Symptom.SymptomType.stomachPain
        let severity = 6.0
        let notes = "After eating dairy"
        let medications = ["Antacid", "Gas-X"]
        let duration = 30
        let location = "Upper abdomen"
        
        // When
        let symptom = Symptom(
            profileId: profileId,
            type: type,
            severity: severity,
            notes: notes,
            medications: medications,
            durationMinutes: duration,
            bodyLocation: location
        )
        
        // Then
        #expect(symptom.profileId == profileId)
        #expect(symptom.symptomType == type.rawValue)
        #expect(symptom.severity == severity)
        #expect(symptom.notes == notes)
        #expect(symptom.medications == medications)
        #expect(symptom.durationMinutes == duration)
        #expect(symptom.bodyLocation == location)
    }
    
    @Test("Symptom severity bounds")
    func testSymptomSeverityBounds() async throws {
        let profileId = UUID()
        
        // Test upper bound
        let symptom1 = Symptom(profileId: profileId, type: .headache, severity: 15.0)
        #expect(symptom1.severity == 10.0)
        
        // Test lower bound
        let symptom2 = Symptom(profileId: profileId, type: .headache, severity: -5.0)
        #expect(symptom2.severity == 0.0)
        
        // Test valid range
        let symptom3 = Symptom(profileId: profileId, type: .headache, severity: 5.5)
        #expect(symptom3.severity == 5.5)
    }
    
    @Test("Symptom severity levels")
    func testSymptomSeverityLevels() async throws {
        // Mild
        let mild = Symptom(type: .headache, severity: 2.0)
        #expect(mild.severityLevel == .mild)
        
        // Moderate
        let moderate = Symptom(type: .headache, severity: 4.0)
        #expect(moderate.severityLevel == .moderate)
        
        // Severe
        let severe = Symptom(type: .headache, severity: 6.0)
        #expect(severe.severityLevel == .severe)
        
        // Very Severe
        let verySevere = Symptom(type: .headache, severity: 8.0)
        #expect(verySevere.severityLevel == .verySevere)
    }
    
    @Test("Symptom type categories")
    func testSymptomTypeCategories() async throws {
        // Digestive
        #expect(Symptom.SymptomType.bloating.category == .digestive)
        #expect(Symptom.SymptomType.stomachPain.category == .digestive)
        
        // Skin
        #expect(Symptom.SymptomType.rash.category == .skin)
        #expect(Symptom.SymptomType.eczemaFlare.category == .skin)
        
        // Neurological
        #expect(Symptom.SymptomType.headache.category == .neurological)
        #expect(Symptom.SymptomType.migraine.category == .neurological)
        
        // Respiratory
        #expect(Symptom.SymptomType.congestion.category == .respiratory)
        #expect(Symptom.SymptomType.wheezing.category == .respiratory)
        
        // Musculoskeletal
        #expect(Symptom.SymptomType.jointPain.category == .musculoskeletal)
        #expect(Symptom.SymptomType.inflammation.category == .musculoskeletal)
        
        // Other
        #expect(Symptom.SymptomType.anxiety.category == .other)
    }
    
    @Test("Symptom type computed property")
    func testSymptomTypeComputedProperty() async throws {
        // Given
        let symptom = Symptom(type: .migraine, severity: 8.0)
        
        // When/Then
        #expect(symptom.type == .migraine)
        
        // Test invalid symptom type
        symptom.symptomType = "InvalidType"
        #expect(symptom.type == .other)
    }
    
    @Test("All symptom types are categorized")
    func testAllSymptomTypesAreCategorized() async throws {
        // Given
        let allTypes = Symptom.SymptomType.allCases
        
        // When/Then - ensure each type has a category
        for type in allTypes {
            let category = type.category
            #expect(Symptom.SymptomCategory.allCases.contains(category))
        }
    }
}