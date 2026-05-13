import SwiftUI
import UIKit

// MARK: - AppLanguage
enum AppLanguage: String, CaseIterable, Identifiable {
    case arabic  = "ar"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .arabic:  return "العربية"
        case .english: return "English"
        }
    }

    var isRTL: Bool { self == .arabic }
    var direction: LayoutDirection { isRTL ? .rightToLeft : .leftToRight }

    var semanticAttribute: UISemanticContentAttribute {
        isRTL ? .forceRightToLeft : .forceLeftToRight
    }
    var nsTextAlignment: NSTextAlignment { isRTL ? .right : .left }
}

// MARK: - LanguageManager
@Observable final class LanguageManager {

    var current: AppLanguage

    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "ar"
        current = AppLanguage(rawValue: saved) ?? .arabic
    }

    var isRTL: Bool { current.isRTL }
    var direction: LayoutDirection { current.direction }

    // Translate: Arabic first, English second
    func t(_ ar: String, _ en: String) -> String {
        current == .arabic ? ar : en
    }

    // Switch language and apply UIKit appearance immediately
    func set(_ lang: AppLanguage) {
        current = lang
        UserDefaults.standard.set(lang.rawValue, forKey: "appLanguage")
        applyUIKit(lang)
    }

    func applyUIKit(_ lang: AppLanguage) {
        UIView.appearance().semanticContentAttribute            = lang.semanticAttribute
        UINavigationBar.appearance().semanticContentAttribute  = lang.semanticAttribute
        UITabBar.appearance().semanticContentAttribute         = lang.semanticAttribute
        UITableView.appearance().semanticContentAttribute      = lang.semanticAttribute
        UITextField.appearance().textAlignment                 = lang.nsTextAlignment
        UILabel.appearance().textAlignment                     = lang.nsTextAlignment
    }
}
