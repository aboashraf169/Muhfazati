import SwiftUI
import SwiftData

struct PersonDetailView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var context
    @Bindable var person: Person
    let currency: String

    @State private var showAddIncoming = false
    @State private var showAddOutgoing  = false
    @State private var showSettleAll    = false

    private var activeEntries: [PersonTransaction] {
        person.transactions.filter { !$0.isSettled }.sorted { $0.date > $1.date }
    }
    private var settledEntries: [PersonTransaction] {
        person.transactions.filter { $0.isSettled }.sorted { ($0.settledAt ?? $0.date) > ($1.settledAt ?? $1.date) }
    }
    private var totalGave: Double { person.transactions.filter { $0.direction == .theyOweMe }.reduce(0) { $0 + $1.amount } }
    private var totalGot:  Double { person.transactions.filter { $0.direction == .iOweThem  }.reduce(0) { $0 + $1.amount } }

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    AvatarView(name: person.name, size: 84, gradientIndex: abs(person.name.hashValue) % 5)
                    VStack(spacing: 4) {
                        Text(person.name).font(AppFont.name).foregroundStyle(Color.text1)
                        Text(lang.t("\(person.transactions.count) معاملة",
                                    "\(person.transactions.count) transactions"))
                            .font(AppFont.caption).foregroundStyle(Color.text3)
                    }
                    HStack(spacing: 10) {
                        StatCard(label: lang.t("أعطيته",    "I Gave"),    amount: totalGave,              currency: currency)
                        StatCard(label: lang.t("أخذت منه",  "I Got"),     amount: totalGot,               currency: currency)
                        StatCard(label: lang.t("الميزان",   "Balance"),   amount: abs(person.netBalance), currency: currency, isDark: true)
                    }
                    HStack(spacing: 12) {
                        actionButton(label: lang.t("وارد", "Incoming"), icon: "arrow.down.left")  { showAddIncoming = true }
                        actionButton(label: lang.t("صادر", "Outgoing"), icon: "arrow.up.right")   { showAddOutgoing  = true }
                    }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                .listRowBackground(Color.bg).listRowSeparator(.hidden)
            }

            if !activeEntries.isEmpty {
                Section(lang.t("السجل النشط", "Active Records")) {
                    ForEach(activeEntries) { entry in
                        PersonTransactionRowView(entry: entry)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    context.delete(entry); try? context.save()
                                } label: { Label(lang.t("حذف", "Delete"), systemImage: "trash") }

                                Button {
                                    entry.isSettled = true; entry.settledAt = Date(); try? context.save()
                                } label: { Label(lang.t("تسوية", "Settle"), systemImage: "checkmark.circle") }
                                    .tint(.green)
                            }
                    }
                }
            }

            if !settledEntries.isEmpty {
                Section(lang.t("المُسوَّى", "Settled")) {
                    ForEach(settledEntries) { entry in
                        PersonTransactionRowView(entry: entry).opacity(0.45)
                    }
                }
            }

            if activeEntries.isEmpty && settledEntries.isEmpty {
                Section {
                    EmptyStateView(icon: "doc.text",
                                   title: lang.t("لا توجد سجلات", "No Records"),
                                   subtitle: lang.t("ابدأ بتسجيل معاملة مع \(person.name)",
                                                    "Start recording a transaction with \(person.name)"))
                        .listRowBackground(Color.bg).listRowSeparator(.hidden)
                }
            }

            if person.netBalance != 0 {
                Section {
                    Button(lang.t("تسوية الكل", "Settle All")) { showSettleAll = true }
                        .font(AppFont.body).foregroundStyle(Color.expenseColor).frame(maxWidth: .infinity)
                        .confirmationDialog(lang.t("تسوية جميع المبالغ المستحقة؟", "Settle all outstanding amounts?"),
                                            isPresented: $showSettleAll, titleVisibility: .visible) {
                            Button(lang.t("تسوية الكل", "Settle All"), role: .destructive) { settleAll() }
                            Button(lang.t("إلغاء", "Cancel"), role: .cancel) {}
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.bg)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddIncoming) {
            AddPersonTransactionView(person: person, defaultDirection: .iOweThem)
        }
        .sheet(isPresented: $showAddOutgoing) {
            AddPersonTransactionView(person: person, defaultDirection: .theyOweMe)
        }
    }

    private func settleAll() {
        activeEntries.forEach { $0.isSettled = true; $0.settledAt = Date() }
        try? context.save()
    }

    @ViewBuilder
    private func actionButton(label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 14, weight: .medium))
                Text(label).font(AppFont.body)
            }
            .foregroundStyle(Color.text1).frame(maxWidth: .infinity).padding(.vertical, 13)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PersonDetailView(person: PreviewContainer.samplePerson, currency: "₪")
    }
    .modelContainer(PreviewContainer.container)
    .environment(LanguageManager())
}
