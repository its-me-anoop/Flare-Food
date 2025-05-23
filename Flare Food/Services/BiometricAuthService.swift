//
//  BiometricAuthService.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import Foundation
import LocalAuthentication

/// Service for handling biometric authentication
class BiometricAuthService: ObservableObject {
    static let shared = BiometricAuthService()
    
    @Published var isAuthenticated = false
    @Published var isAuthenticationAvailable = false
    @Published var biometricType: LABiometryType = .none
    
    private let context = LAContext()
    
    init() {
        checkBiometricAvailability()
    }
    
    /// Check if biometric authentication is available
    func checkBiometricAvailability() {
        var error: NSError?
        isAuthenticationAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if isAuthenticationAvailable {
            biometricType = context.biometryType
        }
    }
    
    /// Authenticate using biometrics
    func authenticate(reason: String = "Access your Flare Food data") async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }
        
        // Perform authentication
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            await MainActor.run {
                self.isAuthenticated = success
            }
            
            return success
        } catch {
            print("Authentication failed: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Get biometric type string
    var biometricTypeString: String {
        switch biometricType {
        case .none:
            return "None"
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .opticID:
            return "Optic ID"
        @unknown default:
            return "Unknown"
        }
    }
    
    /// Check if biometric authentication is enabled
    var isBiometricEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricAuthEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isBiometricAuthEnabled)
        }
    }
    
    /// Reset authentication state
    func resetAuthentication() {
        isAuthenticated = false
    }
}