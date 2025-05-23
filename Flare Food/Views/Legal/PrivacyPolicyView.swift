//
//  PrivacyPolicyView.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI

/// Privacy Policy view
struct PrivacyPolicyView: View {
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
                LegalWebView(htmlFileName: "privacy-policy")
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
            .navigationTitle("Privacy Policy")
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
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasAcceptedPrivacyPolicy)
            UserDefaults.standard.set("1.0", forKey: UserDefaultsKeys.privacyPolicyVersion)
            onAccept?()
            dismiss()
        }) {
            Text("I Accept the Privacy Policy")
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
    PrivacyPolicyView()
}