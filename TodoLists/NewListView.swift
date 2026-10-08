import SwiftUI

struct NewListView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedColor = "blue"
    @State private var selectedIcon = "list.bullet"

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
            Form {
                Section {
                    VStack(spacing: 20) {
                        Image(systemName: selectedIcon)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 88, height: 88)
                            .background(Color.listColor(named: selectedColor), in: Circle())
                            .shadow(color: Color.listColor(named: selectedColor).opacity(0.35), radius: 12, y: 6)

                        TextField("List Name", text: $name)
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 8, trailing: 0))
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 5), spacing: 16) {
                        ForEach(Color.listPalette, id: \.name) { entry in
                            Circle()
                                .fill(entry.color)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if selectedColor == entry.name {
                                        Image(systemName: "checkmark")
                                            .font(.body.weight(.bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = entry.name
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(selectedIcon == icon ? .white : .primary)
                                .frame(width: 40, height: 40)
                                .background {
                                    if selectedIcon == icon {
                                        Circle().fill(Color.listColor(named: selectedColor))
                                    } else {
                                        Circle().fill(Color(.tertiarySystemFill))
                                    }
                                }
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        store.addList(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            colorName: selectedColor,
                            iconName: selectedIcon
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.large])
    }
}

#Preview {
    NewListView()
        .environmentObject(TodoStore())
}
