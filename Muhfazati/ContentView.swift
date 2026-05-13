import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(LanguageManager.self) private var lang

    var body: some View {
        RootTabView()
            .id(lang.current) // Force full rebuild on language change
            .onAppear {
                DefaultData.seedIfNeeded(context: context)
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewContainer.container)
        .environment(LanguageManager())
}
