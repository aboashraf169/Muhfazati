import SwiftUI

struct WalletCard: View {
    @Environment(LanguageManager.self) private var lang
    let profile: Profile
    var income:  Double = 0
    var expense: Double = 0
    var balance: Double = 0

    @State private var appeared     = false
    @State private var isHidden     = false
    @State private var animBalance  : Double = 0
    @State private var animIncome   : Double = 0
    @State private var animExpense  : Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────
            HStack {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(profile.name)
                        .font(AppFont.bodyBold).foregroundStyle(Color.text1)
                    Text(profile.type.localizedName(lang))
                        .font(AppFont.caption).foregroundStyle(Color.text3)
                }
                Spacer()
                IconAvatarView(icon: profile.type.icon, size: 40, gradientIndex: 1)
            }
            .padding(.bottom, 16)

            // ── Balance ─────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(lang.t("الرصيد الإجمالي", "Total Balance"))
                        .font(AppFont.meta).foregroundStyle(Color.text3)
                    Spacer()
                    // Elegant hide/show button
                    HStack(spacing: 4) {
                        Image(systemName: isHidden ? "eye.slash" : "eye")
                            .font(.system(size: 12, weight: .medium))
                        Text(isHidden ? lang.t("إظهار", "Show") : lang.t("إخفاء", "Hide"))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(Color.text4)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.surface2)
                    .clipShape(Capsule())
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isHidden.toggle()
                        }
                    }
                }

                // Balance number with blur + counting
                Text(NumberFormatter.formatAmount(animBalance, currency: profile.currencyCode))
                    .font(AppFont.balanceLg)
                    .foregroundStyle(balance >= 0 ? Color.text1 : Color.expenseColor)
                    .contentTransition(.numericText(value: animBalance))
                    .blur(radius: isHidden ? 12 : 0)
                    .scaleEffect(isHidden ? 0.97 : 1, anchor: .leading)
                    .animation(.easeInOut(duration: 0.28), value: isHidden)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 18)

            Divider().background(Color.line).padding(.bottom, 16)

            // ── Stats ────────────────────────────────────────────
            HStack(spacing: 0) {
                WalletStat(
                    label: lang.t("الدخل", "Income"),
                    amount: animIncome, currency: profile.currencyCode,
                    icon: "arrow.down.left", color: Color.incomeColor,
                    isHidden: isHidden, delay: 0.0
                )
                Rectangle().fill(Color.line).frame(width: 1, height: 36)
                WalletStat(
                    label: lang.t("المصاريف", "Expenses"),
                    amount: animExpense, currency: profile.currencyCode,
                    icon: "arrow.up.right", color: Color.expenseColor,
                    isHidden: isHidden, delay: 0.08
                )
            }
        }
        .padding(20)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radius))
        .overlay(RoundedRectangle(cornerRadius: AppConstants.radius).stroke(Color.line, lineWidth: 1))
        .shadow(color: Color.ink.opacity(0.05), radius: 12, x: 0, y: 3)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.05)) {
                appeared = true
            }
            withAnimation(.spring(response: 0.65, dampingFraction: 0.82).delay(0.15)) { animBalance = balance }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.28))  { animIncome  = income  }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.38))  { animExpense = expense }
        }
        .onDisappear {
            appeared = false
            animBalance = 0; animIncome = 0; animExpense = 0
        }
        .onChange(of: balance) { _, v in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { animBalance = v }
        }
        .onChange(of: income)  { _, v in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { animIncome  = v }
        }
        .onChange(of: expense) { _, v in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { animExpense = v }
        }
    }
}

// MARK: - Stat tile
private struct WalletStat: View {
    let label: String
    let amount: Double
    let currency: String
    let icon: String
    let color: Color
    let isHidden: Bool
    var delay: Double = 0

    @State private var statAppeared = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(AppFont.meta).foregroundStyle(Color.text3)
                Text(NumberFormatter.formatAmount(amount, currency: currency))
                    .font(AppFont.amount(14)).foregroundStyle(Color.text1)
                    .contentTransition(.numericText(value: amount))
                    .blur(radius: isHidden ? 7 : 0)
                    .animation(.easeInOut(duration: 0.25), value: isHidden)
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(statAppeared ? 1 : 0)
        .offset(y: statAppeared ? 0 : 8)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35 + delay)) {
                statAppeared = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.bg.ignoresSafeArea()
        WalletCard(profile: PreviewContainer.sampleProfile, income: 10_200, expense: 2_890, balance: 7_310)
            .padding(20)
    }
    .modelContainer(PreviewContainer.container)
    .environment(LanguageManager())
}
