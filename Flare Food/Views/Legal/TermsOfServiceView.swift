//
//  TermsOfServiceView.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI

/// Terms of Service view
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hasAccepted = false
    let showAcceptButton: Bool
    let onAccept: (() -> Void)?
    
    init(showAcceptButton: Bool = false, onAccept: (() -> Void)? = nil) {
        self.showAcceptButton = showAcceptButton
        self.onAccept = onAccept
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LegalWebView(htmlFileName: "terms-of-service")
                    .ignoresSafeArea(edges: .bottom)
                
                if showAcceptButton {
                    VStack {
                        Spacer()
                        
                        acceptButton
                            .padding()
                            .background(
                                Color(UIColor.systemBackground)
                                    .opacity(0.95)
                                    .ignoresSafeArea()
                            )
                    }
                }
            }
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showAcceptButton {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private var acceptButton: some View {
        Button(action: {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasAcceptedTermsOfService)
            UserDefaults.standard.set("1.0", forKey: UserDefaultsKeys.termsOfServiceVersion)
            onAccept?()
            dismiss()
        }) {
            Text("I Accept the Terms of Service")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(DesignSystem.Gradients.primary)
                .cornerRadius(DesignSystem.CornerRadius.large)
        }
    }
}

#Preview {
    TermsOfServiceView()
}