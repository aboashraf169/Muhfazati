import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var context
    @Query(sort: \Profile.sortOrder) private var profiles: [Profile]
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    @Binding var activeProfileID: UUID?
    @State private var filterKind: TransactionKind? = nil
    @State private var showProfileSwitcher = false
    @State private var showSettings = false

    private var activeProfile: Profile? {
        profiles.first { $0.id == activeProfileID } ?? profiles.first
    }

    private var profileTransactions: [Transaction] {
        guard let pid = activeProfile?.id else { return [] }
        return allTransactions.filter { $0.profile?.id == pid }
    }

    private var filteredTransactions: [Transaction] {
        guard let kind = filterKind else { return profileTransactions }
        return profileTransactions.filter { $0.kind == kind }
    }

    private var totalIncome:  Double { profileTransactions.filter { $0.kind == .income  }.reduce(0) { $0 + $1.amount } }
    private var totalExpense: Double { profileTransactions.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount } }

    private var groupedByDay: [(key: String, value: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { txn -> String in
            lang.current == .arabic ? txn.date.arabicDayLabel : txn.date.englishDayLabel
        }
        return grouped.map { ($0.key, $0.value) }
            .sorted { a, b in (a.value.first?.date ?? .distantPast) > (b.value.first?.date ?? .distantPast) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Top Bar ──
            HStack(spacing: 10) {
                HStack(spacing: 10) {
                    IconAvatarView(icon: activeProfile?.type.icon ?? "wallet.pass", size: 38, gradientIndex: 1)
                    HStack(spacing: 5) {
                        Text(activeProfile?.name ?? lang.t("محفظتي", "My Wallet"))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.text1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.text3)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { showProfileSwitcher = true }
                Spacer()
                Image(systemName: "gearshape")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color.text2)
                    .contentShape(Rectangle())
                    .onTapGesture { showSettings = true }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)

            // ── Scrollable content ──
            ScrollView {
                VStack(spacing: 0) {
                    if let profile = activeProfile {
                        WalletCard(
                            profile: profile,
                            income: totalIncome,
                            expense: totalExpense,
                            balance: totalIncome - totalExpense
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }

                    SegmentTabs(
                        options: [
                            (lang.t("الكل",      "All"),      nil as TransactionKind?),
                            (lang.t("المصاريف",  "Expenses"), TransactionKind.expense),
                            (lang.t("الدخل",     "Income"),   TransactionKind.income),
                        ],
                        selected: $filterKind
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    Group {
                        if filteredTransactions.isEmpty {
                            EmptyStateView(
                                icon: "arrow.left.arrow.right",
                                title: lang.t("لا توجد معاملات", "No Transactions"),
                                subtitle: lang.t("اضغط + لتسجيل أول معاملة", "Tap + to add your first transaction")
                            )
                        } else {
                            VStack(spacing: 0) {
                                ForEach(groupedByDay, id: \.key) { group in
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(group.key)
                                            .font(AppFont.meta)
                                            .foregroundStyle(Color.text3)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                        ForEach(group.value) { txn in
                                            TransactionRowView(transaction: txn)
                                                .padding(.horizontal, 20)
                                            if txn.id != group.value.last?.id {
                                                Divider().background(Color.line).padding(.leading, 77)
                                            }
                                        }
                                    }
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: filterKind)
                        }
                    }
                    .animation(.easeInOut(duration: 0.22), value: filterKind)

                    Color.clear.frame(height: 100)
                }
            }
        }
        .background(Color.bg)
        .sheet(isPresented: $showProfileSwitcher) {
            ProfileSwitcherSheet(activeProfileID: $activeProfileID)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(activeProfileID: $activeProfileID)
        }
    }
}

// MARK: - Profile Switcher Sheet
struct ProfileSwitcherSheet: View {
    @Environment(LanguageManager.self) private var lang
    @Query(sort: \Profile.sortOrder) private var profiles: [Profile]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Binding var activeProfileID: UUID?
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(lang.t("استخدمت \(profiles.count) من \(AppConstants.maxProfiles)",
                            "Using \(profiles.count) of \(AppConstants.maxProfiles)"))
                    .font(AppFont.caption)
                    .foregroundStyle(Color.text3)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                VStack(spacing: 0) {
                    ForEach(profiles) { profile in
                        HStack(spacing: 14) {
                            IconAvatarView(icon: profile.type.icon, size: 44, gradientIndex: 1)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(profile.name)
                                    .font(AppFont.bodyBold).foregroundStyle(Color.text1)
                                Text(profile.type.localizedName(lang))
                                    .font(AppFont.caption).foregroundStyle(Color.text3)
                            }
                            Spacer()
                            if profile.id == activeProfileID {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.ink)
                            }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 14)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            activeProfileID = profile.id
                            dismiss()
                        }
                        if profile.id != profiles.last?.id { Divider().padding(.leading, 78) }
                    }
                }
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
                .padding(.horizontal, 20).padding(.bottom, 16)

                if profiles.count < AppConstants.maxProfiles {
                    HStack(spacing: 8) {
                        Image(systemName: "plus").font(.system(size: 14, weight: .semibold))
                        Text(lang.t("بروفايل جديد", "New Profile")).font(AppFont.body)
                    }
                    .foregroundStyle(Color.text2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                        .stroke(Color.line, style: StrokeStyle(lineWidth: 1.5, dash: [6])))
                    .contentShape(Rectangle())
                    .onTapGesture { showCreate = true }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 8)
            .background(Color.bg)
            .navigationTitle(lang.t("اختر البروفايل", "Choose Profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(lang.t("تم", "Done")) { dismiss() }.fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showCreate) { CreateProfileView() }
        }
    }
}

#Preview {
    @Previewable @State var id: UUID? = nil
    DashboardView(activeProfileID: $id)
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
        .onAppear { id = PreviewContainer.sampleProfile.id }
}
