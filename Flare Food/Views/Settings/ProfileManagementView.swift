//
//  ProfileManagementView.swift
//  Flare Food
//
//  Created by Anoop Jose on 23/05/2025.
//

import SwiftUI
import SwiftData

/// View for managing multiple user profiles
struct ProfileManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \UserProfile.name) private var profiles: [UserProfile]
    
    @State private var showingAddProfile = false
    @State private var profileToEdit: UserProfile?
    @State private var profileToDelete: UserProfile?
    @State private var showingDeleteAlert = false
    
    private var activeProfile: UserProfile? {
        profiles.first { $0.isActive }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Active Profile Section
                if let active = activeProfile {
                    Section {
                        ProfileRow(profile: active, isActive: true) {
                            profileToEdit = active
                        }
                    } header: {
                        Text("Active Profile")
                    }
                }
                
                // Other Profiles Section
                let otherProfiles = profiles.filter { !$0.isActive }
                if !otherProfiles.isEmpty {
                    Section {
                        ForEach(otherProfiles) { profile in
                            ProfileRow(profile: profile, isActive: false) {
                                switchToProfile(profile)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    profileToDelete = profile
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    profileToEdit = profile
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    } header: {
                        Text("Other Profiles")
                    }
                }
                
                // Add Profile Button
                Section {
                    Button {
                        showingAddProfile = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(DesignSystem.Gradients.primary)
                            Text("Add New Profile")
                                .foregroundColor(DesignSystem.Colors.primaryText)
                        }
                    }
                }
            }
            .navigationTitle("Profiles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddProfile) {
                AddProfileSheet()
            }
            .sheet(item: $profileToEdit) { profile in
                EditProfileSheet(profile: profile)
            }
            .alert("Delete Profile", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    profileToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let profile = profileToDelete {
                        deleteProfile(profile)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this profile? All data associated with this profile will be permanently deleted.")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func switchToProfile(_ profile: UserProfile) {
        // Deactivate all profiles
        for p in profiles {
            p.isActive = false
        }
        
        // Activate selected profile
        profile.isActive = true
        
        do {
            try modelContext.save()
        } catch {
            print("Error switching profile: \(error)")
        }
    }
    
    private func deleteProfile(_ profile: UserProfile) {
        modelContext.delete(profile)
        
        do {
            try modelContext.save()
            
            // If we deleted the active profile, activate the first remaining profile
            if profile.isActive && !profiles.isEmpty {
                if let firstProfile = profiles.first(where: { $0.id != profile.id }) {
                    firstProfile.isActive = true
                    try modelContext.save()
                }
            }
        } catch {
            print("Error deleting profile: \(error)")
        }
        
        profileToDelete = nil
    }
}

// MARK: - Supporting Views

struct ProfileRow: View {
    let profile: UserProfile
    let isActive: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                // Profile Avatar
                profileAvatarView
                
                // Profile Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name ?? "Unnamed Profile")
                        .font(.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    if isActive {
                        Label("Active", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Tap to switch")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                
                Spacer()
                
                if !isActive {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var profileAvatarView: some View {
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
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            
            Text(profile.initials)
                .font(.headline)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0.5)
        }
    }
}

struct AddProfileSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    
    @State private var profileName = ""
    @State private var selectedColor = UserProfile.ProfileColor.blue
    @State private var showingEmptyNameAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Profile Name", text: $profileName)
                } header: {
                    Text("Name")
                }
                
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: DesignSystem.Spacing.small) {
                        ForEach(UserProfile.ProfileColor.allCases, id: \.self) { color in
                            ColorButton(
                                color: color,
                                isSelected: selectedColor == color,
                                action: { selectedColor = color }
                            )
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.small)
                } header: {
                    Text("Profile Color")
                }
            }
            .navigationTitle("New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addProfile()
                    }
                    .fontWeight(.medium)
                }
            }
            .alert("Profile Name Required", isPresented: $showingEmptyNameAlert) {
                Button("OK") { }
            } message: {
                Text("Please enter a name for your profile.")
            }
        }
    }
    
    private func addProfile() {
        guard !profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showingEmptyNameAlert = true
            return
        }
        
        // Deactivate all existing profiles if this is the first profile
        let isFirstProfile = profiles.isEmpty
        if !isFirstProfile {
            for profile in profiles {
                profile.isActive = false
            }
        }
        
        // Create new profile
        let newProfile = UserProfile(
            name: profileName.trimmingCharacters(in: .whitespacesAndNewlines),
            profileColor: selectedColor.rawValue,
            isActive: true
        )
        
        modelContext.insert(newProfile)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error creating profile: \(error)")
        }
    }
}

struct EditProfileSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let profile: UserProfile
    @State private var profileName: String
    @State private var selectedColor: UserProfile.ProfileColor
    @State private var showingEmptyNameAlert = false
    
    init(profile: UserProfile) {
        self.profile = profile
        _profileName = State(initialValue: profile.name ?? "")
        _selectedColor = State(initialValue: UserProfile.ProfileColor(rawValue: profile.profileColor) ?? .blue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Profile Name", text: $profileName)
                } header: {
                    Text("Name")
                }
                
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: DesignSystem.Spacing.small) {
                        ForEach(UserProfile.ProfileColor.allCases, id: \.self) { color in
                            ColorButton(
                                color: color,
                                isSelected: selectedColor == color,
                                action: { selectedColor = color }
                            )
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.small)
                } header: {
                    Text("Profile Color")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.medium)
                }
            }
            .alert("Profile Name Required", isPresented: $showingEmptyNameAlert) {
                Button("OK") { }
            } message: {
                Text("Please enter a name for your profile.")
            }
        }
    }
    
    private func saveProfile() {
        guard !profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showingEmptyNameAlert = true
            return
        }
        
        profile.name = profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.profileColor = selectedColor.rawValue
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error updating profile: \(error)")
        }
    }
}

struct ColorButton: View {
    let color: UserProfile.ProfileColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 50, height: 50)
                
                if isSelected {
                    Circle()
                        .stroke(Color.primary, lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ProfileManagementView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}