import SwiftUI

struct CategoryRowView: View {
    @Environment(LanguageManager.self) private var lang
    let category: Category
    let transactionCount: Int
    let total: Double

    var body: some View {
        HStack(spacing: 14) {
            // Icon 46pt circle
            ZStack {
                Circle()
                    .fill(category.kind == .income ? Color.accentSoft : Color.surface2)
                    .frame(width: 46, height: 46)
                Image(systemName: category.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(category.kind == .income ? Color.incomeColor : Color.text2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(lang.t(category.nameAr, category.nameEn))
                    .font(AppFont.bodyBold)
                    .foregroundStyle(Color.text1)
                if transactionCount > 0 {
                    Text(lang.t("\(transactionCount) معاملة", "\(transactionCount) transactions"))
                        .font(AppFont.caption)
                        .foregroundStyle(Color.text3)
                } else {
                    Text(category.isDefault ? lang.t("افتراضية", "Default") : lang.t("مخصصة", "Custom"))
                        .font(AppFont.caption)
                        .foregroundStyle(Color.text4)
                }
            }

            Spacer()

            if total > 0 {
                Text(NumberFormatter.formatAmount(total, currency: ""))
                    .font(AppFont.amount(13))
                    .foregroundStyle(Color.text2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack(spacing: 0) {
        CategoryRowView(
            category: Category(nameAr: "راتب", nameEn: "Salary", icon: "briefcase.fill", kind: .income, isDefault: true),
            transactionCount: 3,
            total: 8000
        )
        Divider().padding(.leading, 74)
        CategoryRowView(
            category: Category(nameAr: "طعام وشراب", nameEn: "Food", icon: "fork.knife", kind: .expense, isDefault: true),
            transactionCount: 12,
            total: 1200
        )
    }
    .environment(LanguageManager())
    .environment(\.layoutDirection, .rightToLeft)
}
