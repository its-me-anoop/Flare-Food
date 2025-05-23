//
//  ArticleCard.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI

/// Card component for displaying health articles
struct ArticleCard: View {
    let article: Article
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                // Header with category and reading time
                headerSection
                
                // Title and summary
                contentSection
                
                // Footer with author and date
                footerSection
            }
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack {
            // Category badge
            HStack(spacing: DesignSystem.Spacing.xxSmall) {
                Image(systemName: article.category.icon)
                    .font(.caption2)
                
                Text(article.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(categoryColor)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xxSmall)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(categoryColor.opacity(0.1))
            )
            
            Spacer()
            
            // Reading time
            HStack(spacing: DesignSystem.Spacing.xxxSmall) {
                Image(systemName: "clock")
                    .font(.caption2)
                
                Text("\(article.readingTime) min")
                    .font(.caption)
            }
            .foregroundColor(DesignSystem.Colors.secondaryText)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Title
            Text(article.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Summary
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var footerSection: some View {
        HStack {
            // Date
            Text(article.publishDate, style: .date)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            Spacer()
            
            // Read more indicator
            HStack(spacing: DesignSystem.Spacing.xxxSmall) {
                Text("Read More")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
            }
            .foregroundColor(DesignSystem.Colors.primaryGradientStart)
        }
    }
    
    // MARK: - Computed Properties
    
    private var categoryColor: Color {
        switch article.category.color {
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "teal": return .teal
        default: return DesignSystem.Colors.primaryGradientStart
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: DesignSystem.Spacing.medium) {
            ArticleCard(article: Article.sampleArticles[0]) {
                print("Article tapped")
            }
            
            ArticleCard(article: Article.sampleArticles[1]) {
                print("Article tapped")
            }
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}