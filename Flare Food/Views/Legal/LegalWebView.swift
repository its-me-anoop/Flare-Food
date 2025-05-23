//
//  LegalWebView.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI
import WebKit

/// Web view for displaying legal documents
struct LegalWebView: UIViewRepresentable {
    let htmlFileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.backgroundColor = UIColor.systemBackground
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let htmlPath = Bundle.main.path(forResource: htmlFileName, ofType: "html") {
            let htmlUrl = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: LegalWebView
        
        init(_ parent: LegalWebView) {
            self.parent = parent
        }
    }
}