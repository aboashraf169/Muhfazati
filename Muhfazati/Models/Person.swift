import Foundation
import SwiftData

@Model
final class Person {
    var id: UUID
    var name: String
    var phone: String
    var note: String
    var createdAt: Date

    var profile: Profile?

    @Relationship(deleteRule: .cascade, inverse: \PersonTransaction.person)
    var transactions: [PersonTransaction] = []

    init(
        id: UUID = UUID(),
        name: String,
        phone: String = "",
        note: String = ""
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.note = note
        self.createdAt = Date()
    }

    var activeTransactions: [PersonTransaction] {
        transactions.filter { !$0.isSettled }
    }

    var netBalance: Double {
        activeTransactions.reduce(0.0) { total, entry in
            switch entry.direction {
            case .theyOweMe: return total + entry.amount
            case .iOweThem:  return total - entry.amount
            }
        }
    }
}
