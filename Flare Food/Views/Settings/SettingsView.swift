//
//  SettingsView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData
import LocalAuthentication

/// Settings view for app configuration
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserProfile> { $0.isActive }) private var activeProfiles: [UserProfile]
    @Query private var meals: [Meal]
    @Query private var symptoms: [Symptom]
    @Query private var beverages: [FluidEntry]
    @Query private var correlations: [Correlation]
    
    @State private var showingProfileManagement = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingExportOptions = false
    @State private var showingReportOptions = false
    @State private var selectedExportFormat: DataExportService.ExportFormat = .csv
    @State private var selectedReportDateRange: ReportDateRange = .lastMonth
    @State private var showingShareSheet = false
    @State private var exportedData: Data?
    @State private var showingHealthKitPermission = false
    
    @StateObject private var biometricService = BiometricAuthService.shared
    @StateObject private var healthKitService = HealthKitService.shared
    
    private var activeProfile: UserProfile? {
        activeProfiles.first
    }
    
    enum ReportDateRange: String, CaseIterable {
        case lastWeek = "Last Week"
        case lastMonth = "Last Month"
        case lastThreeMonths = "Last 3 Months"
        case lastSixMonths = "Last 6 Months"
        case lastYear = "Last Year"
        case allTime = "All Time"
        
        var dateRange: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .lastWeek:
                return (calendar.date(byAdding: .weekOfYear, value: -1, to: now)!, now)
            case .lastMonth:
                return (calendar.date(byAdding: .month, value: -1, to: now)!, now)
            case .lastThreeMonths:
                return (calendar.date(byAdding: .month, value: -3, to: now)!, now)
            case .lastSixMonths:
                return (calendar.date(byAdding: .month, value: -6, to: now)!, now)
            case .lastYear:
                return (calendar.date(byAdding: .year, value: -1, to: now)!, now)
            case .allTime:
                return (Date.distantPast, now)
            }
        }
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
                
                // Security Section
                Section("Security") {
                    Toggle(biometricService.biometricTypeString, isOn: Binding(
                        get: { activeProfile?.biometricAuthEnabled ?? false },
                        set: { newValue in
                            if let profile = activeProfile {
                                profile.biometricAuthEnabled = newValue
                                biometricService.isBiometricEnabled = newValue
                                if newValue {
                                    // Test authentication when enabling
                                    Task {
                                        let success = await biometricService.authenticate(reason: "Enable biometric authentication for Flare Food")
                                        if !success {
                                            // Revert if authentication failed
                                            await MainActor.run {
                                                profile.biometricAuthEnabled = false
                                                biometricService.isBiometricEnabled = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    ))
                    .disabled(!biometricService.isAuthenticationAvailable)
                    
                    if !biometricService.isAuthenticationAvailable {
                        Text("Biometric authentication is not available on this device")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // HealthKit Section
                Section("HealthKit") {
                    Toggle("Sync to HealthKit", isOn: Binding(
                        get: { activeProfile?.healthKitEnabled ?? false },
                        set: { newValue in
                            if let profile = activeProfile {
                                if newValue && !healthKitService.isAuthorized {
                                    showingHealthKitPermission = true
                                } else {
                                    profile.healthKitEnabled = newValue
                                }
                            }
                        }
                    ))
                    
                    if activeProfile?.healthKitEnabled ?? false {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Syncing water intake", systemImage: "drop.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Label("Syncing caffeine intake", systemImage: "cup.and.saucer.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let lastSync = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastHealthKitSync) as? Date {
                            HStack {
                                Text("Last synced")
                                Spacer()
                                Text(lastSync, style: .relative)
                                    .foregroundColor(.secondary)
                            }
                            .font(.caption)
                        }
                    }
                    
                    if !healthKitService.isHealthKitAvailable {
                        Text("HealthKit is not available on this device")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Data & Privacy Section
                Section("Data & Privacy") {
                    Toggle("iCloud Sync", isOn: .constant(activeProfile?.iCloudSyncEnabled ?? true))
                    
                    Button {
                        showingExportOptions = true
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
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
                
                // Report Generation Section
                Section("Reports") {
                    Button {
                        showingReportOptions = true
                    } label: {
                        Label("Generate PDF Report", systemImage: "doc.richtext")
                            .foregroundColor(.accentColor)
                    }
                    
                    HStack {
                        Text("Include data from")
                        Spacer()
                        Text(selectedReportDateRange.rawValue)
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                ensureUserProfile()
            }
            .sheet(isPresented: $showingExportOptions) {
                exportOptionsSheet
            }
            .sheet(isPresented: $showingReportOptions) {
                reportOptionsSheet
            }
            .sheet(isPresented: $showingShareSheet) {
                if let exportedData = exportedData {
                    ShareSheet(items: [exportedData])
                }
            }
            .alert("HealthKit Permission", isPresented: $showingHealthKitPermission) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please grant HealthKit permission in Settings to sync your hydration data.")
            }
            .task {
                if activeProfile?.healthKitEnabled ?? false && !healthKitService.isAuthorized {
                    let authorized = await healthKitService.requestAuthorization()
                    if authorized, let profile = activeProfile {
                        profile.healthKitEnabled = true
                    }
                }
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
    
    // MARK: - Sheet Views
    
    private var exportOptionsSheet: some View {
        NavigationStack {
            Form {
                Section("Export Format") {
                    ForEach(DataExportService.ExportFormat.allCases, id: \.self) { format in
                        HStack {
                            Text(format.rawValue)
                            Spacer()
                            if selectedExportFormat == format {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExportFormat = format
                        }
                    }
                }
                
                Section {
                    Button("Export Data") {
                        exportData()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingExportOptions = false
                    }
                }
            }
        }
    }
    
    private var reportOptionsSheet: some View {
        NavigationStack {
            Form {
                Section("Date Range") {
                    ForEach(ReportDateRange.allCases, id: \.self) { range in
                        HStack {
                            Text(range.rawValue)
                            Spacer()
                            if selectedReportDateRange == range {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedReportDateRange = range
                        }
                    }
                }
                
                Section {
                    Button("Generate Report") {
                        generatePDFReport()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Report Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingReportOptions = false
                    }
                }
            }
        }
    }
    
    // MARK: - Export Methods
    
    private func exportData() {
        let exportService = DataExportService.shared
        
        if let data = exportService.exportAllData(
            meals: meals,
            symptoms: symptoms,
            beverages: beverages,
            format: selectedExportFormat
        ) {
            exportedData = data
            showingExportOptions = false
            showingShareSheet = true
        }
    }
    
    private func generatePDFReport() {
        let pdfService = PDFReportService.shared
        let dateRange = selectedReportDateRange.dateRange
        
        // Filter data by date range
        let filteredMeals = meals.filter { $0.timestamp >= dateRange.start && $0.timestamp <= dateRange.end }
        let filteredSymptoms = symptoms.filter { $0.timestamp >= dateRange.start && $0.timestamp <= dateRange.end }
        let filteredBeverages = beverages.filter { $0.timestamp >= dateRange.start && $0.timestamp <= dateRange.end }
        let filteredCorrelations = correlations.filter { $0.lastCalculated >= dateRange.start }
        
        if let data = pdfService.generateReport(
            from: dateRange.start,
            to: dateRange.end,
            meals: filteredMeals,
            symptoms: filteredSymptoms,
            beverages: filteredBeverages,
            correlations: filteredCorrelations
        ) {
            exportedData = data
            showingReportOptions = false
            showingShareSheet = true
        }
    }
}

// ShareSheet is now defined in Views/Components/ShareSheet.swift

#Preview {
    SettingsView()
        .modelContainer(for: [
            Food.self,
            Meal.self,
            FoodItem.self,
            Symptom.self,
            Correlation.self,
            UserProfile.self,
            MealReminderTime.self,
            FluidEntry.self
        ], inMemory: true)
}