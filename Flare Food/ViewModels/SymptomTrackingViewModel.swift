//
//  SymptomTrackingViewModel.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftUI
import SwiftData

/// View model for symptom tracking functionality
@MainActor
final class SymptomTrackingViewModel: ObservableObject {
    /// The data service for database operations
    let dataService: DataServiceProtocol
    
    /// Selected symptom type
    @Published var selectedSymptomType: Symptom.SymptomType = .stomachPain
    
    /// Selected timestamp for the symptom
    @Published var selectedTimestamp: Date = Date()
    
    /// Symptom severity (0-10)
    @Published var severity: Double = 5.0
    
    /// Notes about the symptom
    @Published var notes: String = ""
    
    /// Medications taken
    @Published var medications: [String] = []
    
    /// New medication input
    @Published var newMedication: String = ""
    
    /// Duration in minutes
    @Published var durationMinutes: String = ""
    
    /// Body location (for applicable symptoms)
    @Published var bodyLocation: String = ""
    
    /// Recent symptoms for quick reference
    @Published var recentSymptoms: [Symptom] = []
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    /// Error message
    @Published var errorMessage: String?
    
    /// Show success animation
    @Published var showSuccessAnimation: Bool = false
    
    /// Filter for symptom category
    @Published var selectedCategory: Symptom.SymptomCategory? = nil
    
    /// Filtered symptom types based on selected category
    var filteredSymptomTypes: [Symptom.SymptomType] {
        if let category = selectedCategory {
            return Symptom.SymptomType.allCases.filter { $0.category == category }
        }
        return Symptom.SymptomType.allCases
    }
    
    /// Initializes the view model
    /// - Parameter dataService: The data service for database operations
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        Task {
            await loadRecentSymptoms()
        }
    }
    
    /// Loads recent symptoms
    func loadRecentSymptoms() async {
        isLoading = true
        do {
            recentSymptoms = try dataService.fetchRecentSymptoms(limit: 10)
        } catch {
            errorMessage = "Failed to load recent symptoms: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    /// Adds a medication to the list
    func addMedication() {
        let trimmed = newMedication.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        medications.append(trimmed)
        newMedication = ""
    }
    
    /// Removes a medication at the specified index
    /// - Parameter index: The index to remove
    func removeMedication(at index: Int) {
        guard index < medications.count else { return }
        medications.remove(at: index)
    }
    
    /// Quickly logs a symptom based on a recent entry
    /// - Parameter symptom: The recent symptom to use as template
    func quickLogFromRecent(_ symptom: Symptom) {
        selectedSymptomType = symptom.type
        severity = symptom.severity
        notes = symptom.notes ?? ""
        medications = symptom.medications
        if let duration = symptom.durationMinutes {
            durationMinutes = "\(duration)"
        }
        bodyLocation = symptom.bodyLocation ?? ""
        
        // Scroll to top or focus on form
    }
    
    /// Saves the symptom
    func saveSymptom() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Parse duration
            var duration: Int? = nil
            if !durationMinutes.isEmpty {
                duration = Int(durationMinutes)
            }
            
            // Get active profile ID
            guard let profileId = try dataService.getActiveProfileId() else {
                errorMessage = "No active profile found. Please select a profile in settings."
                isLoading = false
                return
            }
            
            // Create symptom
            let symptom = Symptom(
                profileId: profileId,
                type: selectedSymptomType,
                timestamp: selectedTimestamp,
                severity: severity,
                notes: notes.isEmpty ? nil : notes,
                medications: medications,
                durationMinutes: duration,
                bodyLocation: bodyLocation.isEmpty ? nil : bodyLocation
            )
            
            // Save to database
            try dataService.saveSymptom(symptom)
            
            // Show success animation
            showSuccessAnimation = true
            
            // Reset form after a delay
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            resetForm()
            
            // Reload recent symptoms
            await loadRecentSymptoms()
            
        } catch {
            errorMessage = "Failed to save symptom: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Resets the form to initial state
    func resetForm() {
        selectedSymptomType = .stomachPain
        selectedTimestamp = Date()
        severity = 5.0
        notes = ""
        medications = []
        newMedication = ""
        durationMinutes = ""
        bodyLocation = ""
        showSuccessAnimation = false
        selectedCategory = nil
    }
    
    /// Gets suggested body locations based on symptom type
    var suggestedBodyLocations: [String] {
        switch selectedSymptomType {
        case .headache, .migraine:
            return ["Forehead", "Temples", "Back of head", "One side", "Both sides"]
        case .stomachPain, .bloating:
            return ["Upper abdomen", "Lower abdomen", "Left side", "Right side", "Center"]
        case .jointPain:
            return ["Knees", "Elbows", "Shoulders", "Hips", "Ankles", "Wrists", "Fingers"]
        case .rash, .hives, .eczemaFlare:
            return ["Face", "Arms", "Legs", "Chest", "Back", "Hands", "Feet"]
        default:
            return []
        }
    }
    
    /// Common medications for quick selection
    var commonMedications: [String] {
        switch selectedSymptomType.category {
        case .digestive:
            return ["Antacid", "Pepto-Bismol", "Gas-X", "Imodium", "Probiotics"]
        case .neurological:
            return ["Ibuprofen", "Acetaminophen", "Aspirin", "Migraine medication"]
        case .skin:
            return ["Antihistamine", "Hydrocortisone cream", "Moisturizer", "Steroid cream"]
        case .respiratory:
            return ["Inhaler", "Decongestant", "Antihistamine", "Cough syrup"]
        case .musculoskeletal:
            return ["Ibuprofen", "Acetaminophen", "Ice pack", "Heat pad", "Topical cream"]
        case .other:
            return ["Ibuprofen", "Acetaminophen", "Antihistamine"]
        }
    }
}