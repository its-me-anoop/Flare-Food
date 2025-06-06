//
//  PressableButtonStyle.swift
//  Flare Food
//
//  Created by Assistant on 2025-05-23.
//

import SwiftUI

/// Button style providing a subtle press animation.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
