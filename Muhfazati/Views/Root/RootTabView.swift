import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(LanguageManager.self) private var lang
    @Query(sort: \Profile.sortOrder) private var profiles: [Profile]
    @State private var activeProfileID: UUID? = nil
    @State private var selectedTab: Tab = .home
    @State private var showAddTransaction = false

    enum Tab { case home, categories, statistics, settings }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack { DashboardView(activeProfileID: $activeProfileID) }
                case .categories:
                    NavigationStack { CategoriesRootView(activeProfileID: $activeProfileID) }
                case .statistics:
                    StatisticsView(activeProfileID: $activeProfileID)
                case .settings:
                    NavigationStack { SettingsView(activeProfileID: $activeProfileID) }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.18), value: selectedTab)

            CustomTabBar(
                selected: $selectedTab,
                onFABTap: { showAddTransaction = true },
                homeLabel:       lang.t("الرئيسية",    "Home"),
                categoriesLabel: lang.t("الفئات",      "Categories"),
                statsLabel:      lang.t("الإحصائيات", "Statistics"),
                settingsLabel:   lang.t("الإعدادات",  "Settings")
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            if activeProfileID == nil { activeProfileID = profiles.first?.id }
        }
        .onChange(of: profiles) { _, p in
            if activeProfileID == nil { activeProfileID = p.first?.id }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView(
                existingProfile: profiles.first { $0.id == activeProfileID } ?? profiles.first
            )
        }
    }
}

// MARK: - Custom Tab Bar
private struct CustomTabBar: View {
    @Binding var selected: RootTabView.Tab
    let onFABTap: () -> Void
    let homeLabel: String
    let categoriesLabel: String
    let statsLabel: String
    let settingsLabel: String

    @State private var fabPressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(.regularMaterial)
                .overlay(alignment: .top) { Divider().background(Color.line) }
                .frame(height: 84)
                .ignoresSafeArea(edges: .bottom)

            HStack(spacing: 0) {
                TabBarItem(icon: "house.fill",         label: homeLabel,       isSelected: selected == .home)       { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selected = .home } }
                TabBarItem(icon: "square.grid.2x2.fill",label: categoriesLabel,isSelected: selected == .categories) { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selected = .categories } }

                // FAB
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { fabPressed = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { fabPressed = false }
                        onFABTap()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.ink)
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.ink.opacity(fabPressed ? 0.1 : 0.25), radius: fabPressed ? 4 : 12, x: 0, y: fabPressed ? 1 : 4)
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(fabPressed ? 45 : 0))
                    }
                    .scaleEffect(fabPressed ? 0.88 : 1.0)
                }
                .offset(y: -22)
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)

                TabBarItem(icon: "chart.bar.fill",  label: statsLabel,    isSelected: selected == .statistics) { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selected = .statistics } }
                TabBarItem(icon: "gearshape.fill",  label: settingsLabel, isSelected: selected == .settings)   { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selected = .settings } }
            }
            .padding(.horizontal, 8)
            .frame(height: 84)
            .padding(.bottom, 20)
        }
        .frame(height: 84)
    }
}

private struct TabBarItem: View {
    let icon: String; let label: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.text1 : Color.text4)
                    .scaleEffect(isSelected ? 1.12 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                Text(label)
                    .font(AppFont.tabLabel)
                    .foregroundStyle(isSelected ? Color.text1 : Color.text4)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    RootTabView()
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
}
