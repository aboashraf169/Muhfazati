import SwiftUI

struct PersonRowView: View {
    @Environment(LanguageManager.self) private var lang
    let person: Person
    let currency: String

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(name: person.name, size: 46, gradientIndex: abs(person.name.hashValue) % 5)
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name).font(AppFont.bodyBold).foregroundStyle(Color.text1)
                Text(lang.t("\(person.transactions.count) معاملة", "\(person.transactions.count) transactions"))
                    .font(AppFont.caption).foregroundStyle(Color.text3)
            }
            Spacer()
            if person.netBalance != 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(NumberFormatter.formatAmount(abs(person.netBalance), currency: currency))
                        .font(AppFont.amount(13, weight: .semibold))
                        .foregroundStyle(person.netBalance > 0 ? Color.incomeColor : Color.expenseColor)
                    Text(person.netBalance > 0 ? lang.t("لك", "Owed to you") : lang.t("عليك", "You owe"))
                        .font(AppFont.chip).foregroundStyle(Color.text4)
                }
            } else {
                Text(lang.t("متوازن", "Balanced"))
                    .font(AppFont.chip).foregroundStyle(Color.text4)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.surface2).clipShape(Capsule())
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    List {
        PersonRowView(person: PreviewContainer.samplePerson, currency: "₪")
    }
    .modelContainer(PreviewContainer.container)
    .environment(LanguageManager())
}
