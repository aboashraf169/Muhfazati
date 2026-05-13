import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(LanguageManager.self) private var lang
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    private var income:  [Category] { categories.filter { $0.kind == .income  } }
    private var expense: [Category] { categories.filter { $0.kind == .expense } }

    var body: some View {
        List {
            Section(lang.t("الدخل", "Income")) {
                ForEach(income) { cat in
                    HStack(spacing: 14) {
                        Image(systemName: cat.icon).frame(width: 20).foregroundStyle(Color.incomeColor)
                        Text(lang.t(cat.nameAr, cat.nameEn)).font(AppFont.body)
                        Spacer()
                        if cat.isDefault {
                            Text(lang.t("افتراضية", "Default"))
                                .font(AppFont.chip).foregroundStyle(Color.text4)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.surface2).clipShape(Capsule())
                        }
                    }
                }
            }
            Section(lang.t("المصاريف", "Expenses")) {
                ForEach(expense) { cat in
                    HStack(spacing: 14) {
                        Image(systemName: cat.icon).frame(width: 20).foregroundStyle(Color.text2)
                        Text(lang.t(cat.nameAr, cat.nameEn)).font(AppFont.body)
                        Spacer()
                        if cat.isDefault {
                            Text(lang.t("افتراضية", "Default"))
                                .font(AppFont.chip).foregroundStyle(Color.text4)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.surface2).clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .navigationTitle(lang.t("الفئات", "Categories"))
    }
}
