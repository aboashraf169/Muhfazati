import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(Color.text4)
            Text(title)
                .font(AppFont.bodyBold)
                .foregroundStyle(Color.text2)
            Text(subtitle)
                .font(AppFont.caption)
                .foregroundStyle(Color.text3)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(icon: "arrow.left.arrow.right", title: "لا توجد معاملات", subtitle: "اضغط + لتسجيل أول معاملة")
        .environment(\.layoutDirection, .rightToLeft)
}
