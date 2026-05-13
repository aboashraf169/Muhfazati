import Foundation

// MARK: - String: Arabic → English digits
extension String {
    /// Converts Eastern Arabic (٠١٢…) and Persian (۰۱۲…) numerals to ASCII digits.
    var toEnglishDigits: String {
        var s = self
        let eastern = ["٠","١","٢","٣","٤","٥","٦","٧","٨","٩"]
        let persian  = ["۰","۱","۲","۳","۴","۵","۶","۷","۸","۹"]
        for (i, ch) in eastern.enumerated() { s = s.replacingOccurrences(of: ch, with: "\(i)") }
        for (i, ch) in persian.enumerated()  { s = s.replacingOccurrences(of: ch, with: "\(i)") }
        // Also replace Arabic decimal comma with period
        s = s.replacingOccurrences(of: "٫", with: ".")
        return s
    }
}

extension NumberFormatter {
    static let amount: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        f.locale = Locale(identifier: "en_US_POSIX")
        f.usesGroupingSeparator = true
        f.groupingSeparator = ","
        return f
    }()

    static func formatAmount(_ value: Double, currency: String = "") -> String {
        let formatted = amount.string(from: NSNumber(value: abs(value))) ?? "0"
        return currency.isEmpty ? formatted : "\(formatted) \(currency)"
    }
}
