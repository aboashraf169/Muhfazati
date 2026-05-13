import SwiftUI

struct TransactionRowView: View {
    @Environment(LanguageManager.self) private var lang
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 13) {
            // Icon
            ZStack {
                Circle()
                    .fill(transaction.kind == .income ? Color.accentSoft : Color.surface2)
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.categoryIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(transaction.kind == .income ? Color.incomeColor : Color.text2)
            }

            // Name + category chip
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.categoryName)
                    .font(AppFont.bodyBold)
                    .foregroundStyle(Color.text1)

                HStack(spacing: 6) {
                    if !transaction.note.isEmpty {
                        Text(transaction.note)
                            .font(AppFont.caption)
                            .foregroundStyle(Color.text3)
                            .lineLimit(1)
                    }
                    Text(lang.current == .arabic ? transaction.date.arabicDayLabel : transaction.date.englishDayLabel)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.text4)
                }
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(sign + NumberFormatter.formatAmount(transaction.amount, currency: ""))
                    .font(AppFont.amount(14, weight: .semibold))
                    .foregroundStyle(transaction.kind == .income ? Color.incomeColor : Color.text1)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }

    private var sign: String { transaction.kind == .income ? "+" : "-" }
}

#Preview {
    VStack(spacing: 0) {
        TransactionRowView(transaction: PreviewContainer.sampleTransaction)
        Divider().padding(.leading, 57)
        TransactionRowView(transaction: Transaction(amount: 320, kind: .expense, note: "بقالة", categoryName: "طعام وشراب", categoryIcon: "fork.knife"))
    }
    .modelContainer(PreviewContainer.container)
    .padding(.horizontal)
    .environment(LanguageManager())
    .environment(\.layoutDirection, .rightToLeft)
}
