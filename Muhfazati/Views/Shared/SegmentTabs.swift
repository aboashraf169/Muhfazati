import SwiftUI

struct SegmentTabs<T: Hashable>: View {
    let options: [(label: String, value: T)]
    @Binding var selected: T
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.value) { option in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = option.value
                    }
                } label: {
                    Text(option.label)
                        .font(AppFont.body)
                        .fontWeight(selected == option.value ? .semibold : .regular)
                        .foregroundStyle(selected == option.value ? Color.text1 : Color.text3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            if selected == option.value {
                                RoundedRectangle(cornerRadius: AppConstants.radiusSm - 2)
                                    .fill(Color.surface)
                                    .shadow(color: Color.ink.opacity(0.06), radius: 4, x: 0, y: 2)
                                    .matchedGeometryEffect(id: "tab_bg", in: ns)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.surface2)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusSm))
    }
}

#Preview {
    @Previewable @State var selected = "all"
    SegmentTabs(
        options: [("الكل", "all"), ("المصاريف", "expense"), ("الدخل", "income")],
        selected: $selected
    )
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
