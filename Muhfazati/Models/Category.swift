import Foundation
import SwiftData

enum CategoryKind: String, Codable, CaseIterable {
    case income  = "income"
    case expense = "expense"
}

@Model
final class Category {
    var id: UUID
    var nameAr: String
    var nameEn: String
    var icon: String
    var kind: CategoryKind
    var isDefault: Bool
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        nameAr: String,
        nameEn: String,
        icon: String,
        kind: CategoryKind,
        isDefault: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.icon = icon
        self.kind = kind
        self.isDefault = isDefault
        self.sortOrder = sortOrder
    }
}
