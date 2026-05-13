import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \Profile.sortOrder) private var profiles: [Profile]

    var existingProfile: Profile? = nil
    var existing: Transaction? = nil

    @State private var kind: TransactionKind = .expense
    @State private var amountText: String = ""
    @State private var selectedCategory: Category? = nil
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var selectedProfileID: UUID? = nil
    @State private var amountScale: CGFloat = 1.0

    private var activeProfile: Profile? {
        if let id = selectedProfileID { return profiles.first { $0.id == id } }
        return existingProfile ?? profiles.first
    }
    private var currentCategories: [Category] {
        categories.filter { ($0.kind == .income) == (kind == .income) }
    }
    private var canSave: Bool {
        guard let a = Double(amountText.toEnglishDigits), a > 0 else { return false }
        return selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Amount area
                VStack(spacing: 12) {
                    // Profile chip selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(profiles) { p in
                                Button { selectedProfileID = p.id } label: {
                                    Text(p.name)
                                        .font(AppFont.chip)
                                        .foregroundStyle(selectedProfileID == p.id || (selectedProfileID == nil && p.id == activeProfile?.id) ? Color.surface : Color.text2)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(selectedProfileID == p.id || (selectedProfileID == nil && p.id == activeProfile?.id) ? Color.ink : Color.surface2)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Type toggle
                    HStack(spacing: 12) {
                        TypeToggleButton(title: lang.t("مصروف", "Expense"), isSelected: kind == .expense) { kind = .expense; selectedCategory = nil }
                        TypeToggleButton(title: lang.t("دخل", "Income"),   isSelected: kind == .income)  { kind = .income;  selectedCategory = nil }
                    }
                    .padding(.horizontal, 20)

                    // Amount
                    TextField("0", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(AppFont.amountInput)
                        .foregroundStyle(Color.text1)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .scaleEffect(amountScale)
                        .onChange(of: amountText) { _, newVal in
                            amountText = newVal.toEnglishDigits
                            withAnimation(.spring(response: 0.18, dampingFraction: 0.45)) { amountScale = 1.1 }
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.6).delay(0.1)) { amountScale = 1.0 }
                        }
                }
                .padding(.vertical, 24)
                .background(Color.surface2)

                ScrollView {
                    VStack(spacing: 0) {
                        // Category grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text(lang.t("الفئة", "Category"))
                                .font(AppFont.meta).foregroundStyle(Color.text3)
                                .padding(.horizontal, 20)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(currentCategories) { cat in
                                    CategoryCell(category: cat, isSelected: selectedCategory?.id == cat.id, lang: lang)
                                        .onTapGesture { selectedCategory = cat }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 16)

                        Divider().background(Color.line)

                        // Form
                        VStack(spacing: 0) {
                            InlineField(label: lang.t("التاريخ", "Date")) {
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .datePickerStyle(.compact).labelsHidden()
                                    .environment(\.layoutDirection, .leftToRight)
                            }
                            Divider().padding(.leading, 20)
                            InlineField(label: lang.t("ملاحظة", "Note")) {
                                TextField(lang.t("اختياري", "Optional"), text: $note)
                                    .font(AppFont.body).foregroundStyle(Color.text1)
                                    .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                            }
                        }
                        .background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                        .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
                        .padding(.horizontal, 20).padding(.top, 16)

                        // Save
                        Button { save() } label: {
                            Text(lang.t("حفظ المعاملة", "Save Transaction"))
                                .font(AppFont.bodyBold).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(canSave ? Color.ink : Color.text4)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                        }
                        .disabled(!canSave)
                        .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 40)
                    }
                }
            }
            .background(Color.bg)
            .navigationTitle(lang.t("معاملة جديدة", "New Transaction"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lang.t("إلغاء", "Cancel")) { dismiss() }
                }
            }
            .onAppear { prefill() }
        }
    }

    private func prefill() {
        guard let t = existing else { return }
        kind = t.kind; amountText = NumberFormatter.formatAmount(t.amount)
        note = t.note; date = t.date
        selectedCategory = categories.first { $0.nameAr == t.categoryName || $0.nameEn == t.categoryName }
    }

    private func save() {
        guard let amount = Double(amountText.toEnglishDigits), let cat = selectedCategory else { return }
        let profile = activeProfile
        if let t = existing {
            t.amount = amount; t.kind = kind; t.note = note; t.date = date
            t.categoryName = lang.current == .arabic ? cat.nameAr : cat.nameEn
            t.categoryIcon = cat.icon
        } else {
            let t = Transaction(amount: amount, kind: kind, note: note, date: date,
                                categoryName: lang.current == .arabic ? cat.nameAr : cat.nameEn,
                                categoryIcon: cat.icon)
            t.profile = profile; context.insert(t)
        }
        try? context.save(); dismiss()
    }
}

private struct TypeToggleButton: View {
    let title: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.body)
                .foregroundStyle(isSelected ? .white : Color.text2)
                .frame(maxWidth: .infinity).padding(.vertical, 10)
                .background(isSelected ? Color.ink : Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusSm))
                .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusSm)
                    .stroke(isSelected ? Color.clear : Color.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryCell: View {
    let category: Category; let isSelected: Bool; let lang: LanguageManager
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.ink : Color.surface2)
                    .frame(width: 52, height: 52)
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? .white : Color.text2)
            }
            Text(lang.t(category.nameAr, category.nameEn))
                .font(.system(size: 9))
                .foregroundStyle(isSelected ? Color.text1 : Color.text3)
                .lineLimit(1)
        }
    }
}

private struct InlineField<Content: View>: View {
    let label: String; @ViewBuilder let content: Content
    var body: some View {
        HStack {
            Text(label).font(AppFont.meta).foregroundStyle(Color.text3)
            Spacer()
            content
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
}
