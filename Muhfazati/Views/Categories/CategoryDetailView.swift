import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    @Environment(LanguageManager.self) private var lang
    let category: Category
    let currency: String

    @Query private var allTransactions: [Transaction]
    @State private var filter: TransactionKind? = nil

    private var transactions: [Transaction] {
        let byCategory = allTransactions.filter {
            $0.categoryName == category.nameAr || $0.categoryName == category.nameEn
        }
        guard let f = filter else { return byCategory.sorted { $0.date > $1.date } }
        return byCategory.filter { $0.kind == f }.sorted { $0.date > $1.date }
    }

    private var total: Double { transactions.reduce(0) { $0 + $1.amount } }

    private var groupedByDay: [(key: String, value: [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { txn in
            lang.current == .arabic ? txn.date.arabicDayLabel : txn.date.englishDayLabel
        }
        return grouped.map { ($0.key, $0.value) }
            .sorted { ($0.value.first?.date ?? .distantPast) > ($1.value.first?.date ?? .distantPast) }
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Summary card ──
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(category.kind == .income ? Color.accentSoft : Color(.tertiarySystemBackground))
                        .frame(width: 52, height: 52)
                    Image(systemName: category.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(category.kind == .income ? Color.incomeColor : Color.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(lang.t(category.nameAr, category.nameEn))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(lang.t("\(transactions.count) معاملة", "\(transactions.count) transactions"))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(lang.t("الإجمالي", "Total"))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                    Text(NumberFormatter.formatAmount(total, currency: currency))
                        .font(.system(size: 17, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(Color.primary)
                }
            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color(.separator), lineWidth: 1))
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // ── Filter tabs ──
            SegmentTabs(
                options: [
                    (lang.t("الكل", "All"), nil as TransactionKind?),
                    (lang.t("المصاريف", "Expenses"), TransactionKind.expense),
                    (lang.t("الدخل", "Income"), TransactionKind.income)
                ],
                selected: $filter
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Divider()

            // ── Transactions list ──
            if transactions.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: lang.t("لا توجد معاملات", "No Transactions"),
                    subtitle: lang.t("لم يتم تسجيل أي معاملة في هذه الفئة", "No transactions recorded in this category")
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(groupedByDay, id: \.key) { group in
                            VStack(alignment: .leading, spacing: 0) {
                                Text(group.key)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)

                                ForEach(group.value) { txn in
                                    TransactionRowView(transaction: txn)
                                        .padding(.horizontal, 20)
                                    if txn.id != group.value.last?.id {
                                        Divider().padding(.leading, 77)
                                    }
                                }
                            }
                        }
                        Color.clear.frame(height: 100)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(lang.t(category.nameAr, category.nameEn))
        .navigationBarTitleDisplayMode(.large)
    }
}
