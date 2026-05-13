import SwiftUI
import SwiftData

struct AddPersonTransactionView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let person: Person
    var defaultDirection: LedgerDirection = .theyOweMe

    @State private var amountText = ""
    @State private var direction: LedgerDirection
    @State private var desc = ""
    @State private var date = Date()

    init(person: Person, defaultDirection: LedgerDirection = .theyOweMe) {
        self.person = person
        self.defaultDirection = defaultDirection
        self._direction = State(initialValue: defaultDirection)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(direction == .theyOweMe
                         ? lang.t("أعطيته", "I gave them")
                         : lang.t("أخذت منه", "They gave me"))
                        .font(AppFont.meta).foregroundStyle(Color.text3)
                    TextField("0", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(AppFont.amountInput).foregroundStyle(Color.text1)
                        .multilineTextAlignment(.center)
                        .onChange(of: amountText) { _, v in amountText = v.toEnglishDigits }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40).background(Color.surface2)

                Form {
                    Section {
                        Picker(lang.t("الاتجاه", "Direction"), selection: $direction) {
                            Text(lang.t("أعطيته مالاً", "I gave money")).tag(LedgerDirection.theyOweMe)
                            Text(lang.t("أعطوني مالاً", "They gave money")).tag(LedgerDirection.iOweThem)
                        }
                        .pickerStyle(.segmented)
                        .environment(\.layoutDirection, .leftToRight)
                    }
                    Section(lang.t("الوصف", "Description")) {
                        TextField(lang.t("سبب المبلغ...", "Reason for amount..."), text: $desc)
                    }
                    Section(lang.t("التاريخ", "Date")) {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .environment(\.layoutDirection, .leftToRight)
                    }
                }
            }
            .background(Color.bg)
            .navigationTitle(lang.t("تسجيل معاملة", "Record Transaction"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lang.t("إلغاء", "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(lang.t("حفظ", "Save")) { save() }
                        .fontWeight(.semibold)
                        .disabled((Double(amountText.toEnglishDigits) ?? 0) <= 0)
                }
            }
        }
    }

    private func save() {
        guard let amount = Double(amountText.toEnglishDigits), amount > 0 else { return }
        let entry = PersonTransaction(amount: amount, direction: direction, desc: desc, date: date)
        entry.person = person
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}

#Preview {
    AddPersonTransactionView(person: PreviewContainer.samplePerson)
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
}
