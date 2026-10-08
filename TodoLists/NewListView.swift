import SwiftUI

struct NewListView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedColor = "yellow"
    @State private var selectedIcon = "list.bullet"
    @State private var appeared = false

    private let icons = [
        "list.bullet",
        "cart",
        "briefcase",
        "house",
        "heart",
        "star",
        "bookmark",
        "flag",
        "gift",
        "airplane",
        "book",
        "leaf",
    ]

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KaminTheme.black.ignoresSafeArea()

                GeometryReader { geo in
                    OrganicBlob(color: KaminTheme.green.opacity(0.7), rotation: -8)
                        .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.35)
                        .offset(x: -geo.size.width * 0.25, y: geo.size.height * 0.55)
                    OrganicBlob(color: KaminTheme.burgundy.opacity(0.45), rotation: 20)
                        .frame(width: geo.size.width * 0.6, height: geo.size.height * 0.25)
                        .offset(x: geo.size.width * 0.5, y: 40)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NEW LIST")
                                .font(KaminTheme.heroTitle)
                                .foregroundStyle(KaminTheme.yellow)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)

                            Text("NAME IT. COLOR IT. OWN IT.")
                                .font(KaminTheme.meta)
                                .foregroundStyle(KaminTheme.muted)
                                .tracking(1.2)
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                        VStack(spacing: 20) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(.black)
                                .frame(width: 84, height: 84)
                                .background(
                                    Color.listColor(named: selectedColor),
                                    in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(KaminTheme.yellow.opacity(0.7), lineWidth: 1.5)
                                )
                                .scaleEffect(appeared ? 1 : 0.86)
                                .animation(.spring(response: 0.45, dampingFraction: 0.7), value: selectedColor)
                                .animation(.spring(response: 0.45, dampingFraction: 0.7), value: selectedIcon)

                            VStack(spacing: 8) {
                                TextField("List name", text: $name)
                                    .font(.system(size: 28, weight: .regular, design: .serif))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.white)
                                    .tint(KaminTheme.yellow)

                                HairlineDivider()
                                    .frame(maxWidth: 220)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("COLOR")
                                .font(KaminTheme.sectionLabel)
                                .foregroundStyle(KaminTheme.yellow)
                                .tracking(1.5)

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 5),
                                spacing: 14
                            ) {
                                ForEach(Color.listPalette, id: \.name) { entry in
                                    Button {
                                        selectedColor = entry.name
                                    } label: {
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(entry.color)
                                            .frame(height: 40)
                                            .overlay {
                                                if selectedColor == entry.name {
                                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                        .stroke(KaminTheme.yellow, lineWidth: 2.5)
                                                    Image(systemName: "checkmark")
                                                        .font(.caption.weight(.bold))
                                                        .foregroundStyle(.black)
                                                }
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("ICON")
                                .font(KaminTheme.sectionLabel)
                                .foregroundStyle(KaminTheme.yellow)
                                .tracking(1.5)

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6),
                                spacing: 10
                            ) {
                                ForEach(icons, id: \.self) { icon in
                                    Button {
                                        selectedIcon = icon
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(selectedIcon == icon ? .black : .white)
                                            .frame(width: 42, height: 42)
                                            .background {
                                                if selectedIcon == icon {
                                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                        .fill(Color.listColor(named: selectedColor))
                                                } else {
                                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                        .stroke(KaminTheme.hairline, lineWidth: 1)
                                                }
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CANCEL") { dismiss() }
                        .font(KaminTheme.sectionLabel)
                        .foregroundStyle(.white.opacity(0.85))
                        .tracking(1)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("DONE") {
                        store.addList(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            colorName: selectedColor,
                            iconName: selectedIcon
                        )
                        dismiss()
                    }
                    .font(KaminTheme.sectionLabel.weight(.bold))
                    .foregroundStyle(canSave ? .black : .black.opacity(0.35))
                    .tracking(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(canSave ? KaminTheme.yellow : KaminTheme.yellow.opacity(0.35), in: Capsule())
                    .disabled(!canSave)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                    appeared = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NewListView()
        .environmentObject(TodoStore())
}
