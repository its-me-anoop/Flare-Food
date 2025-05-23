//
//  BiometricLockView.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI

/// Lock screen view for biometric authentication
struct BiometricLockView: View {
    @StateObject private var authService = BiometricAuthService.shared
    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            
            VStack(spacing: 40) {
                // App icon
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(DesignSystem.Gradients.primary)
                    .shadow(color: DesignSystem.Colors.primaryGradientStart.opacity(0.3), 
                           radius: 20, x: 0, y: 10)
                
                // Lock icon and text
                VStack(spacing: 20) {
                    Image(systemName: authService.biometricType == .faceID ? "faceid" : "touchid")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .opacity(isAuthenticating ? 0.5 : 1.0)
                        .scaleEffect(isAuthenticating ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isAuthenticating)
                    
                    Text("Flare Food is Locked")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Use \(authService.biometricTypeString) to unlock")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Authenticate button
                Button(action: authenticate) {
                    HStack {
                        Image(systemName: authService.biometricType == .faceID ? "faceid" : "touchid")
                            .font(.system(size: 20))
                        
                        Text("Unlock with \(authService.biometricTypeString)")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(DesignSystem.Colors.primaryGradientStart)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .cornerRadius(DesignSystem.CornerRadius.large)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .disabled(isAuthenticating)
                .opacity(isAuthenticating ? 0.6 : 1.0)
            }
            .padding()
        }
        .alert("Authentication Failed", isPresented: $showError) {
            Button("Try Again", action: authenticate)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Automatically attempt authentication on appear
            authenticate()
        }
    }
    
    private func authenticate() {
        isAuthenticating = true
        
        Task {
            let success = await authService.authenticate()
            
            await MainActor.run {
                isAuthenticating = false
                
                if !success && !authService.isAuthenticated {
                    errorMessage = "Authentication failed. Please try again."
                    showError = true
                }
            }
        }
    }
}

#Preview {
    BiometricLockView()
}