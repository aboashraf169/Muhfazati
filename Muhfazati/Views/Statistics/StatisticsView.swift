import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(LanguageManager.self) private var lang
    @Query(sort: \Profile.sortOrder) private var profiles: [Profile]
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    @Binding var activeProfileID: UUID?
    @State private var period: StatPeriod = .month

    enum StatPeriod: String, CaseIterable {
        case week, month, quarter, year
        func label(_ lang: LanguageManager) -> String {
            switch self {
            case .week:    return lang.t("أسبوع",   "Week")
            case .month:   return lang.t("شهر",     "Month")
            case .quarter: return lang.t("3 أشهر",  "3 Months")
            case .year:    return lang.t("سنة",     "Year")
            }
        }
        func netLabel(_ lang: LanguageManager) -> String {
            switch self {
            case .week:    return lang.t("آخر أسبوع",   "Last Week")
            case .month:   return lang.t("آخر شهر",     "Last Month")
            case .quarter: return lang.t("آخر 3 أشهر",  "Last 3 Months")
            case .year:    return lang.t("آخر سنة",     "Last Year")
            }
        }
    }

    private var activeProfile: Profile? { profiles.first { $0.id == activeProfileID } ?? profiles.first }
    private var currency: String { activeProfile?.currencyCode ?? "₪" }

    private var transactions: [Transaction] {
        guard let pid = activeProfile?.id else { return [] }
        let now = Date()
        let cutoff: Date
        switch period {
        case .week:    cutoff = Calendar.current.date(byAdding: .day,   value: -7,  to: now)!
        case .month:   cutoff = Calendar.current.date(byAdding: .month, value: -1,  to: now)!
        case .quarter: cutoff = Calendar.current.date(byAdding: .month, value: -3,  to: now)!
        case .year:    cutoff = Calendar.current.date(byAdding: .year,  value: -1,  to: now)!
        }
        return allTransactions.filter { $0.profile?.id == pid && $0.date >= cutoff }
    }

    private var income:  Double { transactions.filter { $0.kind == .income  }.reduce(0) { $0 + $1.amount } }
    private var expense: Double { transactions.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount } }
    private var net:     Double { income - expense }
    private var savingRate: Double { guard income > 0 else { return 0 }; return max(0, min(1, net / income)) }

    private var expenseByCategory: [(name: String, icon: String, total: Double, pct: Double)] {
        guard expense > 0 else { return [] }
        let grouped = Dictionary(grouping: transactions.filter { $0.kind == .expense }) { $0.categoryName }
        return grouped.map { key, vals in
            let t = vals.reduce(0) { $0 + $1.amount }
            return (key, vals.first?.categoryIcon ?? "questionmark", t, t / expense)
        }.sorted { $0.total > $1.total }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(lang.t("الإحصائيات", "Statistics"))
                    .font(.system(size: 22, weight: .bold)).foregroundStyle(Color.text1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 14)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(StatPeriod.allCases, id: \.self) { p in
                            Button { withAnimation(.easeInOut(duration: 0.15)) { period = p } } label: {
                                Text(p.label(lang))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(period == p ? .white : Color.text2)
                                    .padding(.horizontal, 16).padding(.vertical, 8)
                                    .background(period == p ? Color.ink : Color.surface2)
                                    .clipShape(Capsule())
                            }.buttonStyle(.plain)
                        }
                    }.padding(.horizontal, 20)
                }.padding(.bottom, 20)

                if transactions.isEmpty {
                    EmptyStateView(icon: "chart.bar",
                                   title: lang.t("لا بيانات", "No Data"),
                                   subtitle: lang.t("سجّل معاملاتك لترى إحصائياتك", "Record transactions to see your statistics"))
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 16) {
                        VStack(spacing: 10) {
                            Text(lang.t("نظرة عامة", "Overview"))
                                .font(.system(size: 13, weight: .medium)).foregroundStyle(Color.text3)
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)

                            HStack(spacing: 10) {
                                OverviewCard(icon: "arrow.down.left", label: lang.t("الدخل", "Income"),     amount: income,  currency: currency, color: Color.incomeColor)
                                OverviewCard(icon: "arrow.up.right",  label: lang.t("المصاريف", "Expenses"), amount: expense, currency: currency, color: Color.expenseColor)
                            }.padding(.horizontal, 20)

                            NetBalanceCard(net: net, currency: currency, savingRate: savingRate, periodLabel: period.netLabel(lang),
                                           savingsLabel: lang.t("ادخار", "Savings"),
                                           positiveMsg: lang.t("دخلك يغطي مصاريفك ✓", "Income covers expenses ✓"),
                                           negativeMsg: lang.t("مصاريفك تجاوزت دخلك", "Expenses exceed income"),
                                           netLabel: lang.t("صافي", "Net"))
                                .padding(.horizontal, 20)
                        }

                        DailyBarChart(transactions: transactions, currency: currency,
                                      title: lang.t("آخر 7 أيام", "Last 7 Days"),
                                      expensesLabel: lang.t("مصاريف", "Expenses"),
                                      incomeLabel: lang.t("دخل", "Income"),
                                      lang: lang)
                            .padding(.horizontal, 20)

                        if !expenseByCategory.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(lang.t("أين ذهبت أموالك؟", "Where did your money go?"))
                                    .font(.system(size: 13, weight: .medium)).foregroundStyle(Color.text3).padding(.horizontal, 20)

                                VStack(spacing: 0) {
                                    ForEach(Array(expenseByCategory.prefix(5).enumerated()), id: \.element.name) { idx, item in
                                        CategoryStatRow(item: item, currency: currency, rank: idx + 1)
                                            .padding(.horizontal, 16).padding(.vertical, 12)
                                        if idx < min(4, expenseByCategory.count - 1) { Divider().padding(.leading, 16) }
                                    }
                                }
                                .background(Color.surface)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                                .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                Color.clear.frame(height: 100)
            }
        }
        .background(Color.bg)
    }
}

// MARK: - Sub-views
private struct OverviewCard: View {
    let icon, label: String; let amount: Double; let currency: String; let color: Color
    @State private var animAmount: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ZStack { Circle().fill(color.opacity(0.12)).frame(width: 32, height: 32); Image(systemName: icon).font(.system(size: 13, weight: .semibold)).foregroundStyle(color) }
                Text(label).font(.system(size: 13, weight: .medium)).foregroundStyle(Color.text2)
            }
            Text(NumberFormatter.formatAmount(animAmount, currency: currency))
                .font(.system(size: 18, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(Color.text1).minimumScaleFactor(0.7).lineLimit(1)
                .contentTransition(.numericText(value: animAmount))
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(14)
        .background(Color.surface).clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { animAmount = amount }
        }
        .onDisappear { animAmount = 0 }
        .onChange(of: amount) { _, v in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { animAmount = v }
        }
    }
}

private struct NetBalanceCard: View {
    let net, currency: String; let savingRate: Double
    let periodLabel, savingsLabel, positiveMsg, negativeMsg, netLabel: String
    init(net: Double, currency: String, savingRate: Double, periodLabel: String,
         savingsLabel: String, positiveMsg: String, negativeMsg: String, netLabel: String) {
        self.net = NumberFormatter.formatAmount(net, currency: currency)
        self.currency = currency; self.savingRate = savingRate
        self.periodLabel = periodLabel; self.savingsLabel = savingsLabel
        self.positiveMsg = positiveMsg; self.negativeMsg = negativeMsg; self.netLabel = netLabel
        self._isPositive = State(initialValue: net >= 0)
    }
    @State private var isPositive: Bool
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(netLabel) \(periodLabel)").font(.system(size: 13, weight: .medium)).foregroundStyle(Color.text3)
                Text(net).font(.system(size: 26, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(isPositive ? Color.incomeColor : Color.expenseColor)
                Text(isPositive ? positiveMsg : negativeMsg)
                    .font(.system(size: 12)).foregroundStyle(isPositive ? Color.incomeColor : Color.expenseColor)
            }
            Spacer()
            ZStack {
                Circle().stroke(Color.surface2, lineWidth: 6).frame(width: 60, height: 60)
                Circle().trim(from: 0, to: savingRate)
                    .stroke(isPositive ? Color.incomeColor : Color.expenseColor,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60).rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(Int(savingRate * 100))%").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundStyle(Color.text1)
                    Text(savingsLabel).font(.system(size: 9)).foregroundStyle(Color.text3)
                }
            }
        }
        .padding(16).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
    }
}

private struct DailyBarChart: View {
    let transactions: [Transaction]; let currency, title, expensesLabel, incomeLabel: String; let lang: LanguageManager
    private var days: [(label: String, expense: Double, income: Double)] {
        (0..<7).map { i in
            let day = Calendar.current.date(byAdding: .day, value: -(6 - i), to: Date())!
            let dayTxns = transactions.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
            let exp = dayTxns.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount }
            let inc = dayTxns.filter { $0.kind == .income  }.reduce(0) { $0 + $1.amount }
            let fmt = DateFormatter(); fmt.dateFormat = "EEE"
            fmt.locale = Locale(identifier: lang.current == .arabic ? "ar" : "en_US")
            return (fmt.string(from: day), exp, inc)
        }
    }
    private var maxVal: Double { days.flatMap { [$0.expense, $0.income] }.max() ?? 1 }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 13, weight: .medium)).foregroundStyle(Color.text3)
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(days, id: \.label) { day in
                    VStack(spacing: 4) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4).fill(Color.surface2).frame(height: 70)
                            VStack(spacing: 2) {
                                if day.income > 0 { RoundedRectangle(cornerRadius: 3).fill(Color.incomeColor.opacity(0.5)).frame(height: max(4, 60 * (day.income / max(maxVal, 1)))) }
                                if day.expense > 0 { RoundedRectangle(cornerRadius: 3).fill(Color.ink).frame(height: max(4, 60 * (day.expense / max(maxVal, 1)))) }
                            }
                        }.frame(maxWidth: .infinity)
                        Text(day.label).font(.system(size: 9, weight: .medium)).foregroundStyle(Color.text3)
                    }
                }
            }
            HStack(spacing: 16) {
                HStack(spacing: 5) { RoundedRectangle(cornerRadius: 2).fill(Color.ink).frame(width: 12, height: 8); Text(expensesLabel).font(.system(size: 11)).foregroundStyle(Color.text3) }
                HStack(spacing: 5) { RoundedRectangle(cornerRadius: 2).fill(Color.incomeColor.opacity(0.5)).frame(width: 12, height: 8); Text(incomeLabel).font(.system(size: 11)).foregroundStyle(Color.text3) }
            }
        }
        .padding(16).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
    }
}

private struct CategoryStatRow: View {
    let item: (name: String, icon: String, total: Double, pct: Double); let currency: String; let rank: Int
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Text("\(rank)").font(.system(size: 12, weight: .bold)).foregroundStyle(Color.text4).frame(width: 16)
                ZStack { Circle().fill(Color.surface2).frame(width: 34, height: 34); Image(systemName: item.icon).font(.system(size: 13, weight: .medium)).foregroundStyle(Color.text2) }
                Text(item.name).font(.system(size: 15, weight: .medium)).foregroundStyle(Color.text1)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(NumberFormatter.formatAmount(item.total, currency: currency)).font(.system(size: 14, weight: .semibold, design: .rounded).monospacedDigit()).foregroundStyle(Color.text1)
                    Text("\(Int(item.pct * 100))%").font(.system(size: 11)).foregroundStyle(Color.text3)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.surface2).frame(height: 4)
                    RoundedRectangle(cornerRadius: 3).fill(Color.ink).frame(width: geo.size.width * item.pct, height: 4)
                }
            }.frame(height: 4).padding(.leading, 28)
        }
    }
}

#Preview {
    @Previewable @State var id: UUID? = nil
    StatisticsView(activeProfileID: $id)
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
        .onAppear { id = PreviewContainer.sampleProfile.id }
}
