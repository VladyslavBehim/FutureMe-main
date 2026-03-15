import SwiftUI
import Combine

// MARK: - App Theme Enum
enum AppTheme: String, CaseIterable {
    case classic = "theme.classic"
    case dark = "theme.dark"
    case neon = "theme.neon"
    
    var title: String {
        switch self {
        case .classic: return "Classic Cosmic"
        case .dark: return "Deep Space Dark"
        case .neon: return "Cyberpunk Neon"
        }
    }
    
    var isPremium: Bool {
        return self != .classic
    }
    
    var primaryColor: Color {
        switch self {
        case .classic: return Color(hex: "7B5EA7")
        case .dark: return Color(hex: "2D3748") // Example muted dark blue
        case .neon: return Color(hex: "00FFCC") // Electric cyan
        }
    }
    
    var backgroundColors: [Color] {
        switch self {
        case .classic:
            return [Color(hex: "070B14"), Color(hex: "100821"), Color(hex: "050A18")]
        case .dark:
            // Absolute black to deep gray
            return [Color.black, Color(hex: "0D0D12"), Color.black]
        case .neon:
            // Very dark with subtle purple/cyan hints
            return [Color(hex: "050014"), Color(hex: "1A0033"), Color(hex: "001A33")]
        }
    }
}

// MARK: - AppStorage Manager
class ThemeSettings: ObservableObject {
    @AppStorage("selectedTheme") private var storedThemeString: String = AppTheme.classic.rawValue
    
    var currentTheme: AppTheme {
        get {
            return AppTheme(rawValue: storedThemeString) ?? .classic
        }
        set {
            storedThemeString = newValue.rawValue
            objectWillChange.send()
        }
    }
}
