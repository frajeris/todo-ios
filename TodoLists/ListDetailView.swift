import SwiftUI

struct ListDetailView: View {
    @EnvironmentObject private var store: TodoStore
    let listID: UUID

    @State private var newItemTitle = ""
    @FocusState private var isAddingFocused: Bool
    @State private var showCompleted = true

    private var list: TodoList? {
        store.lists.first { $0.id == listID }
    }

    private var incompleteItems: [TodoItem] {
        list?.items.filter { !$0.isDone } ?? []
    }

    private var completedItems: [TodoItem] {
        list?.items.filter(\.isDone) ?? []
    }

    var body: some View {
        Group {
            if let list {
                listContent(list)
            } else {
                ContentUnavailableView("List Not Found", systemImage: "list.bullet")
            }
        }
    }

    @ViewBuilder
    private func listContent(_ list: TodoList) -> some View {
        List {
            Section {
                ForEach(incompleteItems) { item in
                    TodoRowView(item: item, accent: list.color) {
                        store.toggleItem(item, in: list)
                    } onTitleChange: { title in
                        store.updateItemTitle(item, in: list, to: title)
                    }
                }
                .onDelete { offsets in
                    let items = incompleteItems
                    for index in offsets {
                        store.deleteItem(items[index], in: list)
                    }
                }

                HStack(spacing: 14) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(list.color)

                    TextField("New Reminder", text: $newItemTitle)
                        .focused($isAddingFocused)
                        .submitLabel(.done)
                        .onSubmit(addItem)
                }
                .padding(.vertical, 2)
            }

            if !completedItems.isEmpty {
                Section {
                    DisclosureGroup(isExpanded: $showCompleted) {
                        ForEach(completedItems) { item in
                            TodoRowView(item: item, accent: list.color) {
                                store.toggleItem(item, in: list)
                            } onTitleChange: { title in
                                store.updateItemTitle(item, in: list, to: title)
                            }
                        }
                        .onDelete { offsets in
                            let items = completedItems
                            for index in offsets {
                                store.deleteItem(items[index], in: list)
                            }
                        }
                    } label: {
                        Text("Completed")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isAddingFocused = true
                    } label: {
                        Label("New Reminder", systemImage: "plus")
                    }

                    if !completedItems.isEmpty {
                        Button(role: .destructive) {
                            store.clearCompleted(in: list)
                        } label: {
                            Label("Clear Completed", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    isAddingFocused = true
                } label: {
                    Label("New Reminder", systemImage: "plus.circle.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(list.color)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.bar)
        }
    }

    private func addItem() {
        guard let list else { return }
        store.addItem(to: list, title: newItemTitle)
        newItemTitle = ""
        isAddingFocused = true
    }
}

struct TodoRowView: View {
    let item: TodoItem
    let accent: Color
    let onToggle: () -> Void
    let onTitleChange: (String) -> Void

    @State private var draftTitle: String = ""

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isDone ? accent : Color.secondary.opacity(0.45))
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .padding(.top, 1)

            TextField("Reminder", text: $draftTitle)
                .strikethrough(item.isDone, color: .secondary)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .submitLabel(.done)
                .onSubmit(commitTitle)
        }
        .padding(.vertical, 2)
        .onAppear {
            draftTitle = item.title
        }
        .onDisappear(perform: commitTitle)
        .onChange(of: item.title) { _, newValue in
            if draftTitle != newValue {
                draftTitle = newValue
            }
        }
    }

    private func commitTitle() {
        let trimmed = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            draftTitle = item.title
        } else if trimmed != item.title {
            onTitleChange(trimmed)
        }
    }
}
