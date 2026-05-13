import SwiftUI
import SwiftData

struct CreateProfileView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Profile.sortOrder) private var profiles: [Profile]

    @State private var name = ""
    @State private var type: ProfileType = .personal
    @State private var selectedIcon = "person.fill"
    @State private var currencyCode = "₪"

    let iconPresets = [
        "person.fill","briefcase.fill","person.2.fill","building.2.fill",
        "cart.fill","house.fill","car.fill","heart.fill",
        "star.fill","laptopcomputer","graduationcap.fill","stethoscope"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "#E8EDE6"), Color(hex: "#C8D2C4")],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 108, height: 108)
                        Image(systemName: selectedIcon).font(.system(size: 40, weight: .medium)).foregroundStyle(Color.text2)
                    }.padding(.top, 8)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(iconPresets, id: \.self) { icon in
                            Button { selectedIcon = icon } label: {
                                ZStack {
                                    Circle().fill(selectedIcon == icon ? Color.ink : Color.surface2).frame(width: 46, height: 46)
                                    Image(systemName: icon).font(.system(size: 17))
                                        .foregroundStyle(selectedIcon == icon ? .white : Color.text2)
                                }
                            }.buttonStyle(.plain)
                        }
                    }.padding(.horizontal, 20)

                    VStack(spacing: 0) {
                        HStack {
                            Text(lang.t("الاسم", "Name")).font(AppFont.meta).foregroundStyle(Color.text3).frame(width: 80, alignment: .leading)
                            TextField(lang.t("مثال: محفظتي", "E.g. My Wallet"), text: $name)
                                .font(AppFont.body).multilineTextAlignment(lang.isRTL ? .trailing : .leading).foregroundStyle(Color.text1)
                        }.padding(.horizontal, 20).padding(.vertical, 14)
                        Divider().padding(.leading, 20)
                        HStack {
                            Text(lang.t("النوع", "Type")).font(AppFont.meta).foregroundStyle(Color.text3).frame(width: 80, alignment: .leading)
                            Spacer()
                            Picker("", selection: $type) {
                                ForEach(ProfileType.allCases, id: \.self) { t in Text(t.localizedName(lang)).tag(t) }
                            }.labelsHidden()
                        }.padding(.horizontal, 20).padding(.vertical, 14)
                        Divider().padding(.leading, 20)
                        HStack {
                            Text(lang.t("العملة", "Currency")).font(AppFont.meta).foregroundStyle(Color.text3).frame(width: 80, alignment: .leading)
                            Spacer()
                            Picker("", selection: $currencyCode) {
                                ForEach(["₪","SAR","USD","AED","KWD","EUR","GBP","EGP","JOD"], id: \.self) { Text($0).tag($0) }
                            }.labelsHidden()
                        }.padding(.horizontal, 20).padding(.vertical, 14)
                    }
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                    .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
                    .padding(.horizontal, 20)

                    Button { save() } label: {
                        Text(lang.t("إنشاء البروفايل", "Create Profile"))
                            .font(AppFont.bodyBold).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.text4 : Color.ink)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 20).padding(.bottom, 40)
                }
            }
            .background(Color.bg)
            .navigationTitle(lang.t("بروفايل جديد", "New Profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button(lang.t("إلغاء", "Cancel")) { dismiss() } }
            }
        }
    }

    private func save() {
        let p = Profile(name: name.trimmingCharacters(in: .whitespaces), type: type,
                        currencyCode: currencyCode, colorHex: "#1F2430", sortOrder: profiles.count)
        context.insert(p); try? context.save(); dismiss()
    }
}

#Preview {
    CreateProfileView()
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
}
