import SwiftUI

extension Color {

    // MARK: — Brand / Ink
    static let ink      = Color(hex: "#1F2430")
    static let inkSoft  = Color(hex: "#2A3142")
    static let inkOnInk = Color.white   // نص فوق خلفية ink (دائماً أبيض)

    // MARK: — Text hierarchy
    static let text1 = Color(hex: "#1F2430")   // عنوان
    static let text2 = Color(hex: "#3D4A5C")   // ثانوي
    static let text3 = Color(hex: "#6B7A8D")   // caption
    static let text4 = Color(hex: "#9BA8B5")   // placeholder

    // MARK: — Backgrounds (Apple system)
    static let bg       = Color(.systemGroupedBackground)
    static let surface  = Color(.secondarySystemGroupedBackground)
    static let surface2 = Color(.tertiarySystemBackground)
    static let surface3 = Color(.systemFill)

    // MARK: — Lines
    static let line  = Color(.separator)
    static let line2 = Color(.opaqueSeparator)

    // MARK: — Accent
    static let accent     = Color(hex: "#4A5D7A")
    static let accentSoft = Color(hex: "#EBF0F7")

    // MARK: — Semantic colors
    static let incomeColor  = Color(hex: "#4A5D7A")
    static let expenseColor = Color(hex: "#C0392B")

    // MARK: — Backward compat
    static let brandPrimary   = ink
    static let brandSecondary = expenseColor
    static let cardBackground = Color(.tertiarySystemBackground)
    static let theyOweMeColor = incomeColor
    static let iOweThemColor  = expenseColor

    // MARK: — Hex init
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int & 0xFF)          / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - App Constants
enum AppConstants {
    static let maxProfiles: Int      = 10
    static let radius: CGFloat       = 20
    static let radiusMd: CGFloat     = 16
    static let radiusSm: CGFloat     = 12
    static let cardPadding: CGFloat  = 20
    static let cornerRadius: CGFloat = 16
}

// MARK: - Profile Colors
let profileColors: [String] = [
    "#1F2430", "#4A5D7A", "#3D4A5C", "#6B7A8D",
    "#C0392B", "#3A6060", "#6A5A3A", "#3A4A6A",
    "#6A3A5A", "#4A6A3A"
]

// MARK: - Avatar Gradients
let avatarGradients: [(Color, Color)] = [
    (Color(hex: "#EFEDE4"), Color(hex: "#D8D3C2")),
    (Color(hex: "#E8EEF5"), Color(hex: "#C8D4E2")),
    (Color(hex: "#ECE8E4"), Color(hex: "#D4CDC2")),
    (Color(hex: "#E6EAED"), Color(hex: "#C4CCD2")),
    (Color(hex: "#EDE8E8"), Color(hex: "#D3C8C8")),
]
