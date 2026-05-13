import SwiftUI
import SwiftData

struct AddPersonView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let profile: Profile

    @State private var name = ""
    @State private var phone = ""
    @State private var note = ""
    @State private var selectedIcon = "person.fill"

    let iconPresets = [
        "person.fill", "building.2.fill", "cart.fill", "wrench.fill",
        "heart.fill", "star.fill", "car.fill", "house.fill",
        "graduationcap.fill", "stethoscope", "fork.knife", "laptopcomputer"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar preview
                    ZStack {
                        Circle().fill(Color.surface2).frame(width: 108, height: 108)
                        Image(systemName: selectedIcon)
                            .font(.system(size: 40, weight: .medium)).foregroundStyle(Color.text2)
                    }.padding(.top, 8)

                    // Icon grid
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

                    // Form
                    VStack(spacing: 0) {
                        FormField(label: lang.t("الاسم", "Name")) {
                            TextField(lang.t("اسم الشخص أو التاجر", "Person or merchant name"), text: $name)
                                .font(AppFont.body)
                                .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                        }
                        Divider().padding(.leading, 20)
                        FormField(label: lang.t("رقم الهاتف", "Phone")) {
                            TextField("05xxxxxxxx", text: $phone)
                                .keyboardType(.phonePad).font(AppFont.body)
                        }
                        Divider().padding(.leading, 20)
                        FormField(label: lang.t("ملاحظة", "Note")) {
                            TextField(lang.t("اختياري", "Optional"), text: $note)
                                .font(AppFont.body)
                        }
                    }
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                    .overlay(RoundedRectangle(cornerRadius: AppConstants.radiusMd).stroke(Color.line, lineWidth: 1))
                    .padding(.horizontal, 20)

                    Button { save() } label: {
                        Text(lang.t("إضافة", "Add"))
                            .font(AppFont.bodyBold).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.text4 : Color.ink)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 20).padding(.bottom, 40)
                }
            }
            .background(Color.bg)
            .navigationTitle(lang.t("شخص جديد", "New Person"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lang.t("إلغاء", "Cancel")) { dismiss() }
                }
            }
        }
    }

    private func save() {
        let person = Person(name: name.trimmingCharacters(in: .whitespaces), phone: phone, note: note)
        person.profile = profile
        context.insert(person)
        try? context.save()
        dismiss()
    }
}

private struct FormField<Content: View>: View {
    let label: String; @ViewBuilder let content: Content
    var body: some View {
        HStack {
            Text(label).font(AppFont.meta).foregroundStyle(Color.text3).frame(width: 90, alignment: .leading)
            content.foregroundStyle(Color.text1)
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
    }
}

#Preview {
    AddPersonView(profile: PreviewContainer.sampleProfile)
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
}
