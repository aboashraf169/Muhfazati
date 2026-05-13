import SwiftUI

// Font sizes match the HTML design spec exactly
enum AppFont {
    // Labels & metadata
    static let tabLabel   = Font.system(size: 10, weight: .medium)
    static let chip       = Font.system(size: 10, weight: .semibold)
    static let meta       = Font.system(size: 11, weight: .medium)
    static let caption    = Font.system(size: 12, weight: .regular)
    static let captionMed = Font.system(size: 12, weight: .medium)

    // Body
    static let body       = Font.system(size: 14, weight: .medium)
    static let bodyBold   = Font.system(size: 14, weight: .semibold)

    // Titles
    static let title      = Font.system(size: 22, weight: .bold)
    static let sectionTitle = Font.system(size: 17, weight: .bold)
    static let name       = Font.system(size: 20, weight: .bold)
    static let greeting   = Font.system(size: 16, weight: .semibold)

    // Numbers (monospaced)
    static func amount(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        Font.system(size: size, weight: weight, design: .rounded).monospacedDigit()
    }

    static let balanceLg  = Font.system(size: 30, weight: .medium, design: .rounded).monospacedDigit()
    static let statNum    = Font.system(size: 32, weight: .semibold, design: .rounded).monospacedDigit()
    static let amountInput = Font.system(size: 54, weight: .medium, design: .rounded).monospacedDigit()

    // Auth
    static let authTitle  = Font.system(size: 26, weight: .bold)
}
