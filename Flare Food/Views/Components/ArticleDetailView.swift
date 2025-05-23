//
//  ArticleDetailView.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI

/// Detailed view for reading a full article
struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    // Article header
                    headerSection
                    
                    // Article content with proper formatting
                    contentSection
                    
                    // Tags
                    if !article.tags.isEmpty {
                        tagsSection
                    }
                }
                .padding(DesignSystem.Spacing.medium)
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        shareArticle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(DesignSystem.Colors.primaryGradientStart)
                            .font(.title3)
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            ForEach(contentParagraphs, id: \.self) { paragraph in
                if paragraph.hasPrefix("**") && paragraph.hasSuffix(":**") {
                    // Section headers
                    Text(paragraph.replacingOccurrences(of: "**", with: "").replacingOccurrences(of: ":", with: ""))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .padding(.top, DesignSystem.Spacing.small)
                } else if paragraph.hasPrefix("•") {
                    // Bullet points
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.small) {
                        Circle()
                            .fill(DesignSystem.Colors.primaryGradientStart)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(formatBulletPoint(paragraph))
                            .font(.body)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .multilineTextAlignment(.leading)
                    }
                } else if !paragraph.isEmpty {
                    // Regular paragraphs
                    Text(paragraph)
                        .font(.body)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.small)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            // Category and reading time
            HStack {
                HStack(spacing: DesignSystem.Spacing.xxSmall) {
                    Image(systemName: article.category.icon)
                        .font(.caption)
                    
                    Text(article.category.rawValue)
                        .font(.subheadline)
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
                
                HStack(spacing: DesignSystem.Spacing.xxxSmall) {
                    Image(systemName: "clock")
                        .font(.caption)
                    
                    Text("\(article.readingTime) min read")
                        .font(.subheadline)
                }
                .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            // Title
            Text(article.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.leading)
            
            // Summary
            Text(article.summary)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.leading)
            
            // Date
            Text(article.publishDate, style: .date)
                .font(.subheadline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            Divider()
                .background(DesignSystem.Colors.secondaryText.opacity(0.3))
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Divider()
                .background(DesignSystem.Colors.secondaryText.opacity(0.3))
            
            Text("Tags")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80), spacing: DesignSystem.Spacing.small)
            ], spacing: DesignSystem.Spacing.small) {
                ForEach(article.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryGradientStart)
                        .padding(.horizontal, DesignSystem.Spacing.small)
                        .padding(.vertical, DesignSystem.Spacing.xxSmall)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                .fill(DesignSystem.Colors.primaryGradientStart.opacity(0.1))
                        )
                }
            }
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
    
    // MARK: - Helper Properties
    
    private var contentParagraphs: [String] {
        article.content
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    // MARK: - Methods
    
    private func formatBulletPoint(_ text: String) -> String {
        var cleaned = text
            .replacingOccurrences(of: "• ", with: "")
            .replacingOccurrences(of: "•", with: "")
        
        // Handle bold text within bullet points
        while cleaned.contains("**") {
            if let startRange = cleaned.range(of: "**"),
               let endRange = cleaned[startRange.upperBound...].range(of: "**") {
                let boldText = String(cleaned[startRange.upperBound..<endRange.lowerBound])
                cleaned = cleaned.replacingCharacters(
                    in: startRange.lowerBound..<cleaned.index(endRange.upperBound, offsetBy: 0),
                    with: boldText
                )
            } else {
                break
            }
        }
        
        return cleaned
    }
    
    private func shareArticle() {
        let shareText = "\(article.title)\n\n\(article.summary)\n\nRead more in Flare Food app!"
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        window.rootViewController?.present(activityViewController, animated: true)
    }
}

#Preview {
    ArticleDetailView(article: Article.sampleArticles[0])
}