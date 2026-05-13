import SwiftUI
import SwiftData

struct CategoriesRootView: View {
    @Environment(LanguageManager.self) private var lang
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \Profile.sortOrder) private var profiles: [Profile]

    @Binding var activeProfileID: UUID?
    @State private var innerTab: InnerTab = .categories
    @State private var showAddPerson = false
    @State private var showAddCategory = false
    @State private var searchText = ""
    @State private var kindFilter: CategoryKind? = nil

    enum InnerTab { case categories, people }

    private var activeProfile: Profile? {
        profiles.first { $0.id == activeProfileID } ?? profiles.first
    }

    private var filteredCategories: [Category] {
        categories.filter { cat in
            let matchesKind = kindFilter == nil || cat.kind == kindFilter
            let name = lang.t(cat.nameAr, cat.nameEn)
            let matchesSearch = searchText.isEmpty || name.localizedCaseInsensitiveContains(searchText)
            return matchesKind && matchesSearch
        }
    }

    private var filteredPeople: [Person] {
        let all = activeProfile?.people.sorted { $0.name < $1.name } ?? []
        guard !searchText.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(lang.t("الفئات", "Categories"))
                        .font(.system(size: 22, weight: .bold)).foregroundStyle(Color.text1)
                    Text(lang.t("تصنّف معاملاتك وتابع أشخاصك", "Organize transactions & track people"))
                        .font(.system(size: 13)).foregroundStyle(Color.text3)
                }
                Spacer()
                Button {
                    if innerTab == .categories { showAddCategory = true }
                    else { showAddPerson = true }
                } label: {
                    Image(systemName: "plus").font(.system(size: 17, weight: .medium)).foregroundStyle(Color.ink)
                }
            }
            .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 14)

            // Inner tabs
            HStack(spacing: 0) {
                TabLineButton(title: lang.t("الفئات", "Categories"), isSelected: innerTab == .categories) {
                    withAnimation(.easeInOut(duration: 0.15)) { innerTab = .categories }
                    searchText = ""; kindFilter = nil
                }
                TabLineButton(title: lang.t("الأشخاص والتجار", "People & Merchants"), isSelected: innerTab == .people) {
                    withAnimation(.easeInOut(duration: 0.15)) { innerTab = .people }
                    searchText = ""; kindFilter = nil
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 12)

            Divider()

            // Search
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundStyle(Color.text3)
                TextField(innerTab == .categories
                          ? lang.t("ابحث في الفئات...", "Search categories...")
                          : lang.t("ابحث في الأشخاص...", "Search people..."),
                          text: $searchText)
                    .font(.system(size: 15)).foregroundStyle(Color.text1)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(Color.text4) }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color.surface2)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusSm))
            .padding(.horizontal, 16).padding(.vertical, 10)

            // Kind filter (categories only)
            if innerTab == .categories {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(label: lang.t("الكل",     "All"),      isSelected: kindFilter == nil)      { kindFilter = nil }
                        FilterChip(label: lang.t("المصاريف", "Expenses"), isSelected: kindFilter == .expense) { kindFilter = .expense }
                        FilterChip(label: lang.t("الدخل",    "Income"),   isSelected: kindFilter == .income)  { kindFilter = .income }
                    }.padding(.horizontal, 16)
                }.padding(.bottom, 8)
            }

            ScrollView {
                VStack(spacing: 0) {
                    if innerTab == .categories { categoriesContent }
                    else { peopleContent }
                    Color.clear.frame(height: 100)
                }
            }
        }
        .background(Color.bg)
        .sheet(isPresented: $showAddPerson) {
            if let p = activeProfile { AddPersonView(profile: p) }
        }
        .sheet(isPresented: $showAddCategory) { AddCategoryView() }
    }

    // MARK: - Categories
    private var categoriesContent: some View {
        VStack(spacing: 0) {
            let income  = filteredCategories.filter { $0.kind == .income }
            let expense = filteredCategories.filter { $0.kind == .expense }
            let currency = activeProfile?.currencyCode ?? "₪"

            if filteredCategories.isEmpty {
                EmptyStateView(icon: "magnifyingglass",
                               title: lang.t("لا نتائج", "No Results"),
                               subtitle: lang.t("جرّب كلمة بحث مختلفة", "Try a different search term"))
                    .padding(.top, 40)
            } else {
                if !income.isEmpty && kindFilter != .expense {
                    SectionLabel(lang.t("الدخل", "Income"))
                    ForEach(income) { cat in
                        NavigationLink { CategoryDetailView(category: cat, currency: currency) } label: {
                            CategoryRowView(category: cat, transactionCount: 0, total: 0)
                        }.buttonStyle(.plain)
                        if cat.id != income.last?.id { Divider().padding(.leading, 74) }
                    }
                }
                if !expense.isEmpty && kindFilter != .income {
                    SectionLabel(lang.t("المصاريف", "Expenses"))
                    ForEach(expense) { cat in
                        NavigationLink { CategoryDetailView(category: cat, currency: currency) } label: {
                            CategoryRowView(category: cat, transactionCount: 0, total: 0)
                        }.buttonStyle(.plain)
                        if cat.id != expense.last?.id { Divider().padding(.leading, 74) }
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - People
    private var peopleContent: some View {
        VStack(spacing: 0) {
            if filteredPeople.isEmpty {
                EmptyStateView(
                    icon: searchText.isEmpty ? "person.2" : "magnifyingglass",
                    title: searchText.isEmpty ? lang.t("لا يوجد أشخاص", "No People") : lang.t("لا نتائج", "No Results"),
                    subtitle: searchText.isEmpty ? lang.t("اضغط + لإضافة شخص أو تاجر", "Tap + to add a person or merchant") : lang.t("جرّب كلمة بحث مختلفة", "Try a different search term")
                ).padding(.top, 40)
            } else {
                ForEach(filteredPeople) { person in
                    NavigationLink {
                        PersonDetailView(person: person, currency: activeProfile?.currencyCode ?? "₪")
                    } label: {
                        PersonRowView(person: person, currency: activeProfile?.currencyCode ?? "₪")
                            .padding(.horizontal, 20)
                    }.buttonStyle(.plain)
                    if person.id != filteredPeople.last?.id { Divider().padding(.leading, 78) }
                }
            }
        }.padding(.top, 4)
    }
}

// MARK: - Add Category
struct AddCategoryView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var name: String = ""
    @State private var kind: CategoryKind = .expense
    @State private var selectedIcon: String = "tag"

    private let icons = [
        "tag","cart","fork.knife","car","house","heart.fill","airplane","gift","gamecontroller","book","music.note",
        "dumbbell","cross.case","tshirt","bag","phone","graduationcap","leaf","pawprint","wrench.and.screwdriver",
        "fuelpump","bus","train.side.front.car","bicycle","lamp.desk","sofa","tv","desktopcomputer","iphone",
        "camera","mic","headphones","creditcard","banknote","briefcase.fill","chart.line.uptrend.xyaxis","building.2",
        "person.2.fill","star","bolt","drop","flame"
    ]

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section(lang.t("اسم الفئة", "Category Name")) {
                    TextField(lang.t("مثال: كهرباء", "Example: Electricity"), text: $name)
                }
                Section(lang.t("النوع", "Type")) {
                    Picker(lang.t("النوع", "Type"), selection: $kind) {
                        Text(lang.t("مصروف", "Expense")).tag(CategoryKind.expense)
                        Text(lang.t("دخل", "Income")).tag(CategoryKind.income)
                    }.pickerStyle(.segmented).environment(\.layoutDirection, .leftToRight)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
                Section(lang.t("الأيقونة", "Icon")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 14) {
                        ForEach(icons, id: \.self) { icon in
                            Button { selectedIcon = icon } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedIcon == icon ? Color.ink : Color(.tertiarySystemBackground))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: icon).font(.system(size: 18))
                                        .foregroundStyle(selectedIcon == icon ? .white : Color.text2)
                                }
                            }.buttonStyle(.plain)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
            }
            .navigationTitle(lang.t("فئة جديدة", "New Category"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button(lang.t("إلغاء", "Cancel")) { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(lang.t("حفظ", "Save")) { save() }.fontWeight(.semibold).disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        let n = name.trimmingCharacters(in: .whitespaces)
        let order = (categories.map { $0.sortOrder }.max() ?? 0) + 1
        context.insert(Category(nameAr: n, nameEn: n, icon: selectedIcon, kind: kind, isDefault: false, sortOrder: order))
        try? context.save(); dismiss()
    }
}

// MARK: - Helpers
private struct FilterChip: View {
    let label: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label).font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? .white : Color.text2)
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(isSelected ? Color.ink : Color.surface2).clipShape(Capsule())
        }.buttonStyle(.plain)
    }
}

private struct SectionLabel: View {
    let text: String; init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.system(size: 12, weight: .medium)).foregroundStyle(Color.text3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20).padding(.vertical, 8).background(Color.surface2)
    }
}

private struct TabLineButton: View {
    let title: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title).font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.text1 : Color.text3)
                Rectangle().fill(isSelected ? Color.ink : Color.clear).frame(height: 2).clipShape(Capsule())
            }
        }.buttonStyle(.plain).frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @State var id: UUID? = nil
    NavigationStack {
        CategoriesRootView(activeProfileID: $id)
    }
    .modelContainer(PreviewContainer.container)
    .environment(LanguageManager())
    .onAppear { id = PreviewContainer.sampleProfile.id }
}
