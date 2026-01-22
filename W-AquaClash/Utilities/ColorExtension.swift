//
//  ColorExtension.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import SwiftUI

extension Color {
    // App Color Scheme
    static let darkBlue = Color(hex: "090F1E")
    static let duskyBlue = Color(hex: "1A2339")
    static let brightBlue = Color(hex: "01A2FF")
    
    // Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Common View Modifiers
struct GameButtonStyle: ViewModifier {
    var isEnabled: Bool = true
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isEnabled ? Color.brightBlue : Color.gray)
            .cornerRadius(12)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

extension View {
    func gameButtonStyle(isEnabled: Bool = true) -> some View {
        modifier(GameButtonStyle(isEnabled: isEnabled))
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.duskyBlue)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
