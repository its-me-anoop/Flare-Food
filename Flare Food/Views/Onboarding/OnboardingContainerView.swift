//
//  OnboardingContainerView.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI

/// Container view for onboarding flow
struct OnboardingContainerView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingComplete: Bool
    
    private let pages = OnboardingData.pages
    
    var body: some View {
        ZStack {
            // Page tab view
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Navigation overlay
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .padding()
                    }
                }
                
                Spacer()
                
                // Page indicator and buttons
                VStack(spacing: 30) {
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? 
                                    DesignSystem.Colors.primaryGradientStart : 
                                    DesignSystem.Colors.secondaryText.opacity(0.3)
                                )
                                .frame(width: 10, height: 10)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        HStack {
                            Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                                .font(.system(size: 18, weight: .semibold))
                            
                            if currentPage < pages.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(DesignSystem.Gradients.primary)
                        .cornerRadius(DesignSystem.CornerRadius.large)
                        .shadow(color: DesignSystem.Colors.primaryGradientStart.opacity(0.3), 
                               radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        withAnimation(.easeInOut(duration: 0.5)) {
            isOnboardingComplete = true
        }
    }
}

#Preview {
    OnboardingContainerView(isOnboardingComplete: .constant(false))
}