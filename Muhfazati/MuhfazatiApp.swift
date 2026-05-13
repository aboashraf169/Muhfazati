import SwiftUI
import SwiftData
import UIKit

@main
struct MuhfazatiApp: App {
    let container: ModelContainer
    @State private var langManager = LanguageManager()

    init() {
        // Apply UIKit direction on launch
        let lang = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "ar") ?? .arabic
        UIView.appearance().semanticContentAttribute            = lang.semanticAttribute
        UINavigationBar.appearance().semanticContentAttribute  = lang.semanticAttribute
        UITabBar.appearance().semanticContentAttribute         = lang.semanticAttribute
        UITableView.appearance().semanticContentAttribute      = lang.semanticAttribute
        UITextField.appearance().textAlignment                 = lang.nsTextAlignment
        UILabel.appearance().textAlignment                     = lang.nsTextAlignment

        do {
            let schema = Schema([
                Profile.self, Transaction.self,
                Category.self, Person.self, PersonTransaction.self,
            ])
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(langManager)
                .environment(\.layoutDirection, langManager.direction)
                .preferredColorScheme(.light)
        }
        .modelContainer(container)
    }
}
