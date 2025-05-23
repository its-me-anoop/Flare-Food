//
//  OnboardingData.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI

/// Represents a single onboarding page
struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let imageColor: Color
    let backgroundColor: Color
}

/// Onboarding data
struct OnboardingData {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track Your Meals",
            description: "Log your meals effortlessly and discover patterns in your eating habits",
            imageName: "fork.knife.circle.fill",
            imageColor: DesignSystem.Colors.primaryGradientStart,
            backgroundColor: DesignSystem.Colors.primaryGradientStart.opacity(0.1)
        ),
        OnboardingPage(
            title: "Monitor Symptoms",
            description: "Track digestive symptoms and find correlations with your diet",
            imageName: "heart.text.square.fill",
            imageColor: DesignSystem.Colors.secondaryGradientStart,
            backgroundColor: DesignSystem.Colors.secondaryGradientStart.opacity(0.1)
        ),
        OnboardingPage(
            title: "Stay Hydrated",
            description: "Track your fluid and caffeine intake throughout the day",
            imageName: "drop.circle.fill",
            imageColor: DesignSystem.Colors.accentGradientStart,
            backgroundColor: DesignSystem.Colors.accentGradientStart.opacity(0.1)
        ),
        OnboardingPage(
            title: "Discover Insights",
            description: "Get personalized insights and health articles to improve your well-being",
            imageName: "chart.line.uptrend.xyaxis.circle.fill",
            imageColor: Color.green,
            backgroundColor: Color.green.opacity(0.1)
        )
    ]
}