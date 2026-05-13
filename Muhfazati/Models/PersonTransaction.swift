import Foundation
import SwiftData

enum LedgerDirection: String, Codable {
    case theyOweMe = "theyOweMe"
    case iOweThem  = "iOweThem"

    var arabicLabel: String {
        switch self {
        case .theyOweMe: return "أعطيتهم"
        case .iOweThem:  return "أعطوني"
        }
    }
}

@Model
final class PersonTransaction {
    var id: UUID
    var amount: Double
    var direction: LedgerDirection
    var desc: String
    var date: Date
    var isSettled: Bool
    var settledAt: Date?

    var person: Person?

    init(
        id: UUID = UUID(),
        amount: Double,
        direction: LedgerDirection,
        desc: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.direction = direction
        self.desc = desc
        self.date = date
        self.isSettled = false
        self.settledAt = nil
    }
}
