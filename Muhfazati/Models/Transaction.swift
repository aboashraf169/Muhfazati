import Foundation
import SwiftData

enum TransactionKind: String, Codable {
    case income  = "income"
    case expense = "expense"

    var arabicName: String {
        switch self {
        case .income:  return "دخل"
        case .expense: return "مصروف"
        }
    }
}

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var kind: TransactionKind
    var note: String
    var date: Date
    var createdAt: Date
    var categoryName: String
    var categoryIcon: String

    var profile: Profile?

    init(
        id: UUID = UUID(),
        amount: Double,
        kind: TransactionKind,
        note: String = "",
        date: Date = Date(),
        categoryName: String,
        categoryIcon: String
    ) {
        self.id = id
        self.amount = amount
        self.kind = kind
        self.note = note
        self.date = date
        self.createdAt = Date()
        self.categoryName = categoryName
        self.categoryIcon = categoryIcon
    }
}
