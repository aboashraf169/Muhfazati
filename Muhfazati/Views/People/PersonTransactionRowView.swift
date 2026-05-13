import SwiftUI

struct PersonTransactionRowView: View {
    @Environment(LanguageManager.self) private var lang
    let entry: PersonTransaction

    private var directionLabel: String {
        switch entry.direction {
        case .theyOweMe: return lang.t("أعطيتهم", "I gave")
        case .iOweThem:  return lang.t("أعطوني",  "They gave me")
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: entry.direction == .theyOweMe ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                .font(.title2)
                .foregroundStyle(entry.direction == .theyOweMe ? Color.theyOweMeColor : Color.iOweThemColor)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.desc.isEmpty ? directionLabel : entry.desc)
                    .font(.subheadline.weight(.medium))
                Text(lang.current == .arabic ? entry.date.arabicDayLabel : entry.date.englishDayLabel)
                    .font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Text(NumberFormatter.formatAmount(entry.amount))
                .font(.system(size: 15, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(entry.direction == .theyOweMe ? Color.theyOweMeColor : Color.iOweThemColor)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        PersonTransactionRowView(entry: PreviewContainer.samplePersonTransaction)
    }
    .modelContainer(PreviewContainer.container)
    .environment(LanguageManager())
}
