import Foundation
import SwiftData

enum ProfileType: String, Codable, CaseIterable {
    case personal    = "personal"
    case business    = "business"
    case partnership = "partnership"

    var arabicName: String {
        switch self {
        case .personal:    return "شخصية"
        case .business:    return "تجارية"
        case .partnership: return "شراكة"
        }
    }

    var englishName: String {
        switch self {
        case .personal:    return "Personal"
        case .business:    return "Business"
        case .partnership: return "Partnership"
        }
    }

    func localizedName(_ lang: LanguageManager) -> String {
        lang.t(arabicName, englishName)
    }

    var icon: String {
        switch self {
        case .personal:    return "person.fill"
        case .business:    return "briefcase.fill"
        case .partnership: return "person.2.fill"
        }
    }
}

@Model
final class Profile {
    var id: UUID
    var name: String
    var type: ProfileType
    var currencyCode: String
    var colorHex: String
    var sortOrder: Int
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Transaction.profile)
    var transactions: [Transaction] = []

    @Relationship(deleteRule: .cascade, inverse: \Person.profile)
    var people: [Person] = []

    init(
        id: UUID = UUID(),
        name: String,
        type: ProfileType = .personal,
        currencyCode: String = "₪",
        colorHex: String = "#1B4FFF",
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.currencyCode = currencyCode
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }

    var totalIncome: Double {
        transactions.filter { $0.kind == .income }.reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Double {
        transactions.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        totalIncome - totalExpense
    }
}
