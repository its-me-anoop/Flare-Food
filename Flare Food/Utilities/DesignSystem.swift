//
//  DesignSystem.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI

/// Design system for Flare Food app
struct DesignSystem {
    
    // MARK: - Colors
    
    struct Colors {
        // Primary gradient colors
        static let primaryGradientStart = Color(red: 255/255, green: 149/255, blue: 0/255) // Orange
        static let primaryGradientEnd = Color(red: 255/255, green: 94/255, blue: 77/255) // Coral
        
        // Secondary gradient colors
        static let secondaryGradientStart = Color(red: 255/255, green: 45/255, blue: 85/255) // Pink
        static let secondaryGradientEnd = Color(red: 255/255, green: 112/255, blue: 142/255) // Light Pink
        
        // Accent gradient colors
        static let accentGradientStart = Color(red: 90/255, green: 200/255, blue: 250/255) // Sky Blue
        static let accentGradientEnd = Color(red: 76/255, green: 110/255, blue: 245/255) // Blue
        
        // Success gradient
        static let successGradientStart = Color(red: 52/255, green: 199/255, blue: 89/255)
        static let successGradientEnd = Color(red: 48/255, green: 176/255, blue: 199/255)
        
        // Background colors - Using system defaults
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
        static let groupedBackground = Color(UIColor.systemGroupedBackground)
        
        // Text colors - Using system defaults
        static let primaryText = Color(UIColor.label)
        static let secondaryText = Color(UIColor.secondaryLabel)
        static let tertiaryText = Color(UIColor.tertiaryLabel)
        
        // Card colors
        static let cardBackground = Color(UIColor.secondarySystemBackground)
    }
    
    // MARK: - Gradients
    
    struct Gradients {
        static let primary = LinearGradient(
            colors: [Colors.primaryGradientStart, Colors.primaryGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let secondary = LinearGradient(
            colors: [Colors.secondaryGradientStart, Colors.secondaryGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let accent = LinearGradient(
            colors: [Colors.accentGradientStart, Colors.accentGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let success = LinearGradient(
            colors: [Colors.successGradientStart, Colors.successGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Shadows
    
    struct Shadows {
        static let smallRadius: CGFloat = 2
        static let mediumRadius: CGFloat = 4
        static let largeRadius: CGFloat = 8
        
        static let smallColor = Color.black.opacity(0.05)
        static let mediumColor = Color.black.opacity(0.08)
        static let largeColor = Color.black.opacity(0.12)
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xxxSmall: CGFloat = 4
        static let xxSmall: CGFloat = 8
        static let xSmall: CGFloat = 12
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 40
    }
}

// MARK: - View Modifiers

/// Card background modifier (replaces glass morphism)
struct CardBackground: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(cornerRadius: CGFloat = DesignSystem.CornerRadius.medium, shadowRadius: CGFloat = 4) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }
}

/// Gradient button style
struct GradientButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    let cornerRadius: CGFloat
    
    init(gradient: LinearGradient = DesignSystem.Gradients.primary, cornerRadius: CGFloat = DesignSystem.CornerRadius.medium) {
        self.gradient = gradient
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(gradient)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: .black.opacity(0.15), radius: configuration.isPressed ? 2 : 4, x: 0, y: configuration.isPressed ? 1 : 2)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Card view modifier
struct CardStyle: ViewModifier {
    let padding: CGFloat
    
    init(padding: CGFloat = DesignSystem.Spacing.medium) {
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - View Extensions

extension View {
    /// Applies card background (replaces glassBackground)
    func cardBackground(cornerRadius: CGFloat = DesignSystem.CornerRadius.medium, shadowRadius: CGFloat = 4) -> some View {
        modifier(CardBackground(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    /// Applies card styling
    func cardStyle(padding: CGFloat = DesignSystem.Spacing.medium) -> some View {
        modifier(CardStyle(padding: padding))
    }
    
    /// Applies gradient background
    func gradientBackground(_ gradient: LinearGradient = DesignSystem.Gradients.primary) -> some View {
        self.background(gradient)
    }
    
    /// Convenience method to replace glassBackground calls
    func glassBackground(cornerRadius: CGFloat = DesignSystem.CornerRadius.medium, shadowRadius: CGFloat = 16) -> some View {
        // Redirects to card background for compatibility
        self.cardBackground(cornerRadius: cornerRadius, shadowRadius: shadowRadius)
    }
}

// MARK: - Custom Components

/// Gradient text view
struct GradientText: View {
    let text: String
    let gradient: LinearGradient
    let font: Font
    
    init(_ text: String, gradient: LinearGradient = DesignSystem.Gradients.primary, font: Font = .headline) {
        self.text = text
        self.gradient = gradient
        self.font = font
    }
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(gradient)
    }
}

/// Floating action button
struct FloatingActionButton: View {
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    
    init(icon: String, gradient: LinearGradient = DesignSystem.Gradients.primary, action: @escaping () -> Void) {
        self.icon = icon
        self.gradient = gradient
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(gradient)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
    }
}

/// Gradient button
struct GradientButton: View {
    let title: String
    let icon: String?
    let gradient: LinearGradient
    let action: () -> Void
    let isDisabled: Bool
    
    init(title: String, icon: String? = nil, gradient: LinearGradient = DesignSystem.Gradients.primary, action: @escaping () -> Void, isDisabled: Bool = false) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.action = action
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isDisabled {
                        Color.gray
                    } else {
                        gradient
                    }
                }
            )
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(color: isDisabled ? .clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .disabled(isDisabled)
    }
}

