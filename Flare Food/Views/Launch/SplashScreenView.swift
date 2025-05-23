//
//  SplashScreenView.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI

/// Animated splash screen view
struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.7
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primaryGradientStart,
                    DesignSystem.Colors.primaryGradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App icon/logo
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .scaleEffect(logoScale)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // App name
                VStack(spacing: 5) {
                    Text("Flare Food")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Track • Discover • Thrive")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(textOpacity)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    logoScale = 1.0
                }
                
                withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                    textOpacity = 1.0
                }
                
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.0)) {
                    isAnimating = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}