import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var context
    @Query(sort: \Profile.sortOrder) private var profiles: [Profile]
    @Binding var activeProfileID: UUID?

    @State private var appLock = false
    @State private var showManageProfiles = false
    @State private var showManageCategories = false
    @State private var showLanguagePicker = false

    private var activeProfile: Profile? { profiles.first { $0.id == activeProfileID } ?? profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        AvatarView(name: activeProfile?.name ?? "م", size: 72, gradientIndex: 1)
                        Circle().fill(Color.ink).frame(width: 24, height: 24)
                            .overlay(Image(systemName: "pencil").font(.system(size: 10, weight: .bold)).foregroundStyle(.white))
                    }
                    Text(activeProfile?.name ?? lang.t("محفظتي", "My Wallet"))
                        .font(AppFont.name).foregroundStyle(Color.text1)
                    Text(activeProfile?.type.localizedName(lang) ?? "")
                        .font(AppFont.caption).foregroundStyle(Color.text3)
                }
                .padding(.top, 24)

                SettingsCard {
                    SettingsRow(icon: "person.crop.rectangle.stack",
                                label: lang.t("إدارة البروفايلات", "Manage Profiles"),
                                detail: lang.t("استخدمت \(profiles.count) من \(AppConstants.maxProfiles)",
                                               "\(profiles.count) of \(AppConstants.maxProfiles)")) {
                        showManageProfiles = true
                    }
                }

                SettingsCard(header: lang.t("الإدارة", "Management")) {
                    SettingsRow(icon: "tag.fill", label: lang.t("إدارة الفئات", "Manage Categories")) { showManageCategories = true }
                    Divider().padding(.leading, 52)
                    SettingsRow(icon: "globe", label: lang.t("اللغة", "Language"), detail: lang.current.displayName) { showLanguagePicker = true }
                    Divider().padding(.leading, 52)
                    SettingsRow(icon: "dollarsign.circle", label: lang.t("العملة", "Currency"), detail: activeProfile?.currencyCode ?? "₪") {}
                }

                SettingsCard(header: lang.t("الأمان والبيانات", "Security & Data")) {
                    SettingsRow(icon: "icloud.and.arrow.up", label: lang.t("النسخ الاحتياطي", "Backup")) {}
                    Divider().padding(.leading, 52)
                    HStack {
                        Image(systemName: "lock.shield.fill").font(.system(size: 16)).foregroundStyle(Color.text2).frame(width: 32)
                        Text(lang.t("قفل التطبيق", "App Lock")).font(AppFont.body).foregroundStyle(Color.text1)
                        Spacer()
                        InkToggle(isOn: $appLock)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 14)
                }

                SettingsCard(header: lang.t("عن التطبيق", "About")) {
                    SettingsRow(icon: "info.circle.fill", label: lang.t("عن محفظتي", "About Muhfazati"), detail: "1.0.0") {}
                }

                Button {} label: {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 15))
                        Text(lang.t("تسجيل الخروج", "Sign Out")).font(AppFont.body)
                    }
                    .foregroundStyle(Color.expenseColor).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                    .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
                }
                .buttonStyle(.plain).padding(.horizontal, 20)

                Color.clear.frame(height: 100)
            }
        }
        .background(Color.bg)
        .sheet(isPresented: $showManageProfiles) { ManageProfilesView(activeProfileID: $activeProfileID) }
        .sheet(isPresented: $showManageCategories) { NavigationStack { CategoryManagementView() } }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet(activeProfileID: $activeProfileID).presentationDetents([.fraction(0.42)])
        }
    }
}

// MARK: - Language Picker Sheet
struct LanguagePickerSheet: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Binding var activeProfileID: UUID?
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text(lang.t("اختر لغة التطبيق", "Choose App Language"))
                    .font(.system(size: 13)).foregroundStyle(Color.text3)
                    .padding(.horizontal, 20).padding(.vertical, 14)

                VStack(spacing: 0) {
                    ForEach(AppLanguage.allCases) { appLang in
                        HStack {
                            Text(appLang.displayName).font(AppFont.body).foregroundStyle(Color.text1)
                            Spacer()
                            if appLang == lang.current {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.ink)
                            }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 18)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard appLang != lang.current else { return }
                            lang.set(appLang)
                            DefaultData.resetDemoData(context: context, lang: appLang)
                            dismiss()
                        }
                        if appLang.id != AppLanguage.allCases.last?.id { Divider().padding(.leading, 20) }
                    }
                }
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
                .padding(.horizontal, 20)

                // Reset demo data button
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise").font(.system(size: 13))
                    Text(lang.t("إعادة ضبط البيانات الافتراضية", "Reset Demo Data"))
                        .font(AppFont.caption)
                }
                .foregroundStyle(Color.text3)
                .padding(.top, 20)
                .contentShape(Rectangle())
                .onTapGesture { showResetConfirm = true }

                Spacer()
            }
            .padding(.top, 8).background(Color.bg)
            .navigationTitle(lang.t("اللغة", "Language"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(lang.t("تم", "Done")) { dismiss() }.fontWeight(.semibold)
                }
            }
            .confirmationDialog(lang.t("إعادة ضبط البيانات", "Reset Demo Data"),
                                isPresented: $showResetConfirm, titleVisibility: .visible) {
                Button(lang.t("إعادة الضبط", "Reset"), role: .destructive) {
                    DefaultData.resetDemoData(context: context, lang: lang.current)
                    dismiss()
                }
                Button(lang.t("إلغاء", "Cancel"), role: .cancel) {}
            } message: {
                Text(lang.t("سيتم حذف جميع البيانات وإعادة ضبطها باللغة الحالية",
                             "All data will be deleted and reset in the current language"))
            }
        }
    }
}

// MARK: - Sub-components
private struct SettingsCard<Content: View>: View {
    var header: String? = nil; @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header { Text(header).font(AppFont.meta).foregroundStyle(Color.text3).padding(.horizontal, 20).padding(.bottom, 8) }
            VStack(spacing: 0) { content }
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
                .padding(.horizontal, 20)
        }
    }
}

private struct SettingsRow: View {
    let icon: String; let label: String; var detail: String? = nil; let action: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 15)).foregroundStyle(Color.text2).frame(width: 20)
            Text(label).font(AppFont.body).foregroundStyle(Color.text1)
            Spacer()
            if let d = detail { Text(d).font(AppFont.caption).foregroundStyle(Color.text3) }
            Image(systemName: "chevron.left").font(.system(size: 12)).foregroundStyle(Color.text4)
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }
}

#Preview {
    @Previewable @State var id: UUID? = nil
    SettingsView(activeProfileID: $id)
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
        .onAppear { id = PreviewContainer.sampleProfile.id }
}
