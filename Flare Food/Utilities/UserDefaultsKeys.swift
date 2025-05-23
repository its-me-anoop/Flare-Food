//
//  UserDefaultsKeys.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import Foundation

/// User defaults keys for app preferences
enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let hasAcceptedPrivacyPolicy = "hasAcceptedPrivacyPolicy"
    static let hasAcceptedTermsOfService = "hasAcceptedTermsOfService"
    static let privacyPolicyVersion = "privacyPolicyVersion"
    static let termsOfServiceVersion = "termsOfServiceVersion"
    static let isBiometricAuthEnabled = "isBiometricAuthEnabled"
    static let isHealthKitEnabled = "isHealthKitEnabled"
    static let lastHealthKitSync = "lastHealthKitSync"
    static let preferredExportFormat = "preferredExportFormat"
    static let appLaunchCount = "appLaunchCount"
    static let lastReviewPromptDate = "lastReviewPromptDate"
}