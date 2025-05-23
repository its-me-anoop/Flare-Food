//
//  SettingsView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData

/// Settings view for app configuration
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserProfile> { $0.isActive }) private var activeProfiles: [UserProfile]
    @State private var showingProfileManagement = false
    
    private var activeProfile: UserProfile? {
        activeProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Profile Management Section
                Section("Profiles") {
                    NavigationLink {
                        ProfileManagementView()
                    } label: {
                        HStack {
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
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    
                                    Text(profile.initials)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0.5)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(profile.name ?? "Unnamed Profile")
                                        .font(.headline)
                                    Text("Active Profile")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Text("Manage")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Profile Section
                Section("Current Profile") {
                    HStack {
                        Label("Name", systemImage: "person.fill")
                        Spacer()
                        Text(activeProfile?.name ?? "Not set")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Member Since", systemImage: "calendar")
                        Spacer()
                        if let joinDate = activeProfile?.joinDate {
                            Text(joinDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Conditions Section
                Section("Health Conditions") {
                    if let conditions = activeProfile?.conditions, !conditions.isEmpty {
                        ForEach(conditions, id: \.self) { condition in
                            Text(condition)
                        }
                    } else {
                        Text("No conditions specified")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Manage Conditions") {
                        // TODO: Show condition selection
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: .constant(activeProfile?.notificationsEnabled ?? true))
                    
                    if activeProfile?.notificationsEnabled ?? true {
                        Button("Meal Reminder Times") {
                            // TODO: Show meal reminder configuration
                        }
                    }
                }
                
                // Data & Privacy Section
                Section("Data & Privacy") {
                    Toggle("iCloud Sync", isOn: .constant(activeProfile?.iCloudSyncEnabled ?? true))
                    Toggle("HealthKit Integration", isOn: .constant(activeProfile?.healthKitEnabled ?? false))
                    Toggle("Face ID / Touch ID", isOn: .constant(activeProfile?.biometricAuthEnabled ?? false))
                }
                
                // Statistics Section
                Section("Statistics") {
                    HStack {
                        Label("Current Streak", systemImage: "flame.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("\(activeProfile?.currentStreak ?? 0) days")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Longest Streak", systemImage: "trophy.fill")
                            .foregroundColor(.yellow)
                        Spacer()
                        Text("\(activeProfile?.longestStreak ?? 0) days")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Total Meals", systemImage: "fork.knife")
                        Spacer()
                        Text("\(activeProfile?.totalMealsLogged ?? 0)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Total Symptoms", systemImage: "heart.text.square")
                        Spacer()
                        Text("\(activeProfile?.totalSymptomsLogged ?? 0)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Export Section
                Section("Export Data") {
                    Button {
                        // TODO: Export PDF report
                    } label: {
                        Label("Generate PDF Report", systemImage: "doc.text")
                    }
                    
                    Button {
                        // TODO: Export raw data
                    } label: {
                        Label("Export Raw Data", systemImage: "square.and.arrow.up")
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Privacy Policy") {
                        // TODO: Show privacy policy
                    }
                    
                    Button("Terms of Service") {
                        // TODO: Show terms
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                ensureUserProfile()
            }
        }
    }
    
    /// Ensures a user profile exists
    private func ensureUserProfile() {
        if activeProfiles.isEmpty {
            let profile = UserProfile()
            profile.isActive = true
            modelContext.insert(profile)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [
            Food.self,
            Meal.self,
            FoodItem.self,
            Symptom.self,
            Correlation.self,
            UserProfile.self,
            MealReminderTime.self
        ], inMemory: true)
}