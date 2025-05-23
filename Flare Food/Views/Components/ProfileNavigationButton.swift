//
//  ProfileNavigationButton.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI
import SwiftData

/// Profile navigation button that appears in the navigation bar
struct ProfileNavigationButton: View {
    @Query(filter: #Predicate<UserProfile> { $0.isActive }) private var activeProfiles: [UserProfile]
    @State private var showingSettings = false
    
    private var activeProfile: UserProfile? {
        activeProfiles.first
    }
    
    var body: some View {
        Button {
            showingSettings = true
        } label: {
            if let profile = activeProfile {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    UserProfile.ProfileColor(rawValue: profile.profileColor)?.color ?? DesignSystem.Colors.primaryGradientStart,
                                    (UserProfile.ProfileColor(rawValue: profile.profileColor)?.color ?? DesignSystem.Colors.primaryGradientStart).opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    
                    Text(profile.initials)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0.5)
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.primaryGradientStart)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ProfileNavigationButton()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}