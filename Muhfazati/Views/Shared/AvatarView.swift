import SwiftUI

struct AvatarView: View {
    let name: String
    let size: CGFloat
    var gradientIndex: Int = 0
    var isDark: Bool = false

    var body: some View {
        ZStack {
            if isDark {
                LinearGradient(
                    colors: [Color(hex: "#5B6478"), Color(hex: "#3A4150")],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            } else {
                let pair = avatarGradients[gradientIndex % avatarGradients.count]
                LinearGradient(
                    colors: [pair.0, pair.1],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }

            Text(String(name.prefix(1)))
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(isDark ? .white : Color.text2)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

struct IconAvatarView: View {
    let icon: String
    let size: CGFloat
    var gradientIndex: Int = 1

    var body: some View {
        ZStack {
            let pair = avatarGradients[gradientIndex % avatarGradients.count]
            LinearGradient(colors: [pair.0, pair.1], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .medium))
                .foregroundStyle(Color.text2)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

#Preview {
    HStack(spacing: 12) {
        AvatarView(name: "محمد", size: 46)
        AvatarView(name: "س", size: 46, gradientIndex: 1)
        AvatarView(name: "ع", size: 46, isDark: true)
        AvatarView(name: "ف", size: 84, gradientIndex: 2)
    }
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
