import SwiftUI
import SwiftData

struct ManageProfilesView: View {
    @Environment(LanguageManager.self) private var lang
    @Query(sort: \Profile.sortOrder) private var profiles: [Profile]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Binding var activeProfileID: UUID?
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Text(lang.t("استخدمت \(profiles.count) من \(AppConstants.maxProfiles)",
                                    "Using \(profiles.count) of \(AppConstants.maxProfiles)"))
                            .font(AppFont.caption).foregroundStyle(Color.text3)
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.vertical, 12)

                    VStack(spacing: 0) {
                        ForEach(profiles) { profile in
                            ProfileListRow(
                                profile: profile,
                                isActive: profile.id == activeProfileID,
                                lang: lang,
                                onTap: { activeProfileID = profile.id },
                                onDelete: profiles.count > 1 ? {
                                    if activeProfileID == profile.id {
                                        activeProfileID = profiles.first { $0.id != profile.id }?.id
                                    }
                                    context.delete(profile)
                                } : nil
                            )
                            if profile.id != profiles.last?.id { Divider().padding(.leading, 70) }
                        }
                    }
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                    .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
                    .padding(.horizontal, 20).padding(.bottom, 16)

                    if profiles.count < AppConstants.maxProfiles {
                        Button { showCreate = true } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus").font(.system(size: 14, weight: .semibold))
                                Text(lang.t("بروفايل جديد", "New Profile")).font(AppFont.body)
                            }
                            .foregroundStyle(Color.text2).frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                                .stroke(Color.line, style: StrokeStyle(lineWidth: 1.5, dash: [6])))
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
            }
            .background(Color.bg)
            .navigationTitle(lang.t("البروفايلات", "Profiles"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lang.t("تم", "Done")) { dismiss() }.fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showCreate) { CreateProfileView() }
        }
    }
}

private struct ProfileListRow: View {
    let profile: Profile; let isActive: Bool; let lang: LanguageManager
    let onTap: () -> Void; var onDelete: (() -> Void)? = nil
    var body: some View {
        HStack(spacing: 14) {
            IconAvatarView(icon: profile.type.icon, size: 44, gradientIndex: 1)
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name).font(AppFont.bodyBold).foregroundStyle(Color.text1)
                Text(profile.type.localizedName(lang)).font(AppFont.caption).foregroundStyle(Color.text3)
            }
            Spacer()
            if isActive { Circle().fill(Color.ink).frame(width: 8, height: 8) }
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .contentShape(Rectangle()).onTapGesture { onTap() }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if let del = onDelete {
                Button(role: .destructive, action: del) {
                    Label(lang.t("حذف", "Delete"), systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var id: UUID? = nil
    ManageProfilesView(activeProfileID: $id)
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
        .onAppear { id = PreviewContainer.sampleProfile.id }
}
