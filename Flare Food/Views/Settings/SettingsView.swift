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
    @Query private var userProfiles: [UserProfile]
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Profile Section
                Section("Profile") {
                    HStack {
                        Label("Name", systemImage: "person.fill")
                        Spacer()
                        Text(userProfile?.name ?? "Not set")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Member Since", systemImage: "calendar")
                        Spacer()
                        if let joinDate = userProfile?.joinDate {
                            Text(joinDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Conditions Section
                Section("Health Conditions") {
                    if let conditions = userProfile?.conditions, !conditions.isEmpty {
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
                    Toggle("Enable Notifications", isOn: .constant(userProfile?.notificationsEnabled ?? true))
                    
                    if userProfile?.notificationsEnabled ?? true {
                        Button("Meal Reminder Times") {
                            // TODO: Show meal reminder configuration
                        }
                    }
                }
                
                // Data & Privacy Section
                Section("Data & Privacy") {
                    Toggle("iCloud Sync", isOn: .constant(userProfile?.iCloudSyncEnabled ?? true))
                    Toggle("HealthKit Integration", isOn: .constant(userProfile?.healthKitEnabled ?? false))
                    Toggle("Face ID / Touch ID", isOn: .constant(userProfile?.biometricAuthEnabled ?? false))
                }
                
                // Statistics Section
                Section("Statistics") {
                    HStack {
                        Label("Current Streak", systemImage: "flame.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("\(userProfile?.currentStreak ?? 0) days")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Longest Streak", systemImage: "trophy.fill")
                            .foregroundColor(.yellow)
                        Spacer()
                        Text("\(userProfile?.longestStreak ?? 0) days")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Total Meals", systemImage: "fork.knife")
                        Spacer()
                        Text("\(userProfile?.totalMealsLogged ?? 0)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Total Symptoms", systemImage: "heart.text.square")
                        Spacer()
                        Text("\(userProfile?.totalSymptomsLogged ?? 0)")
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
        if userProfiles.isEmpty {
            let profile = UserProfile()
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