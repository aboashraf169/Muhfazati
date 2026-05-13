import SwiftUI

struct StatCard: View {
    let label: String
    let amount: Double
    let currency: String
    var isDark: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppFont.meta)
                .foregroundStyle(isDark ? Color.white.opacity(0.65) : Color.text3)

            Text(NumberFormatter.formatAmount(amount, currency: currency))
                .font(AppFont.amount(16, weight: .semibold))
                .foregroundStyle(isDark ? .white : Color.text1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isDark ? Color.ink : Color.surface2)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
    }
}

#Preview {
    HStack(spacing: 10) {
        StatCard(label: "أعطيته", amount: 500, currency: "SAR")
        StatCard(label: "أخذت منه", amount: 200, currency: "SAR")
        StatCard(label: "الميزان", amount: 300, currency: "SAR", isDark: true)
    }
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
