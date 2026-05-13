import SwiftUI

// Custom toggle — 44×26pt, ink background when on
struct InkToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? Color.ink : Color.surface3)
                .frame(width: 44, height: 26)

            Circle()
                .fill(.white)
                .frame(width: 20, height: 20)
                .shadow(color: Color.ink.opacity(0.15), radius: 2, x: 0, y: 1)
                .padding(3)
        }
        .animation(.easeInOut(duration: 0.25), value: isOn)
        .onTapGesture { isOn.toggle() }
    }
}

#Preview {
    @Previewable @State var on = true
    HStack(spacing: 20) {
        InkToggle(isOn: $on)
        InkToggle(isOn: .constant(false))
    }
    .padding()
}
