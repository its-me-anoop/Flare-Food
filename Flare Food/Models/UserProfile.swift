//
//  UserProfile.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftUI
import SwiftData

/// Represents the user's profile and app settings
@Model
final class UserProfile {
    /// Unique identifier
    var id: UUID
    
    /// User's name (optional)
    var name: String?
    
    /// Profile color for visual distinction
    var profileColor: String
    
    /// Whether this is the currently active profile
    var isActive: Bool
    
    /// Date when the user started using the app
    var joinDate: Date
    
    /// User's known conditions (IBS, IBD, eczema, etc.)
    var conditions: [String]
    
    /// Notification preferences
    var notificationsEnabled: Bool
    
    /// Preferred meal reminder times
    var mealReminderTimes: [MealReminderTime]
    
    /// Whether to use Face ID/Touch ID
    var biometricAuthEnabled: Bool
    
    /// Whether to sync with iCloud
    var iCloudSyncEnabled: Bool
    
    /// Whether to integrate with HealthKit
    var healthKitEnabled: Bool
    
    /// Current streak of consecutive logging days
    var currentStreak: Int
    
    /// Longest streak achieved
    var longestStreak: Int
    
    /// Total number of meals logged
    var totalMealsLogged: Int
    
    /// Total number of symptoms logged
    var totalSymptomsLogged: Int
    
    /// Last date the user logged data
    var lastLogDate: Date?
    
    /// Preferred app theme
    var preferredTheme: String
    
    /// Profile initials for avatar
    var initials: String {
        guard let name = name, !name.isEmpty else { return "?" }
        let words = name.split(separator: " ").map(String.init)
        if words.count >= 2 {
            return "\(words[0].first ?? "?")\(words[1].first ?? "?")"
        }
        return String(name.prefix(2))
    }
    
    /// Initializes a new UserProfile
    init(name: String? = nil, profileColor: String = ProfileColor.blue.rawValue, isActive: Bool = false) {
        self.id = UUID()
        self.name = name
        self.profileColor = profileColor
        self.isActive = isActive
        self.joinDate = Date()
        self.conditions = []
        self.notificationsEnabled = true
        self.mealReminderTimes = []
        self.biometricAuthEnabled = false
        self.iCloudSyncEnabled = true
        self.healthKitEnabled = false
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalMealsLogged = 0
        self.totalSymptomsLogged = 0
        self.lastLogDate = nil
        self.preferredTheme = Theme.system.rawValue
    }
}

/// Represents a meal reminder time
@Model
final class MealReminderTime {
    /// Unique identifier
    var id: UUID
    
    /// Meal type for this reminder
    var mealType: String
    
    /// Hour component (24-hour format)
    var hour: Int
    
    /// Minute component
    var minute: Int
    
    /// Whether this reminder is enabled
    var isEnabled: Bool
    
    /// Days of the week this reminder is active (1-7, where 1 is Sunday)
    var activeDays: [Int]
    
    /// Initializes a new MealReminderTime
    /// - Parameters:
    ///   - mealType: The meal type
    ///   - hour: Hour in 24-hour format
    ///   - minute: Minute
    ///   - activeDays: Days of week (defaults to all days)
    init(mealType: Meal.MealType, hour: Int, minute: Int, activeDays: [Int] = [1, 2, 3, 4, 5, 6, 7]) {
        self.id = UUID()
        self.mealType = mealType.rawValue
        self.hour = hour
        self.minute = minute
        self.isEnabled = true
        self.activeDays = activeDays
    }
    
    /// Computed property to get the time as a Date
    var timeAsDate: Date {
        let calendar = Calendar.current
        let components = DateComponents(hour: hour, minute: minute)
        return calendar.date(from: components) ?? Date()
    }
}

// MARK: - User Settings
extension UserProfile {
    /// App theme options
    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
    
    /// Profile color options
    enum ProfileColor: String, CaseIterable {
        case blue = "Blue"
        case purple = "Purple"
        case pink = "Pink"
        case orange = "Orange"
        case green = "Green"
        case red = "Red"
        case yellow = "Yellow"
        case teal = "Teal"
        
        var color: Color {
            switch self {
            case .blue: return .blue
            case .purple: return .purple
            case .pink: return .pink
            case .orange: return .orange
            case .green: return .green
            case .red: return .red
            case .yellow: return .yellow
            case .teal: return .teal
            }
        }
    }
    
    /// Common conditions tracked by the app
    enum CommonCondition: String, CaseIterable {
        case ibs = "IBS (Irritable Bowel Syndrome)"
        case ibd = "IBD (Inflammatory Bowel Disease)"
        case crohns = "Crohn's Disease"
        case ulcerativeColitis = "Ulcerative Colitis"
        case celiac = "Celiac Disease"
        case eczema = "Eczema"
        case psoriasis = "Psoriasis"
        case migraine = "Migraines"
        case longCovid = "Long COVID"
        case foodAllergies = "Food Allergies"
        case foodIntolerances = "Food Intolerances"
        case gerd = "GERD (Acid Reflux)"
        case other = "Other"
    }
    
    /// Update streak information
    func updateStreak(on date: Date) {
        let calendar = Calendar.current
        
        if let lastLog = lastLogDate {
            let daysSinceLastLog = calendar.dateComponents([.day], from: lastLog, to: date).day ?? 0
            
            if daysSinceLastLog == 1 {
                // Consecutive day - increment streak
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if daysSinceLastLog > 1 {
                // Streak broken - reset to 1
                currentStreak = 1
            }
            // If daysSinceLastLog == 0, same day - don't update streak
        } else {
            // First log
            currentStreak = 1
            longestStreak = 1
        }
        
        lastLogDate = date
    }
}