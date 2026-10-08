import SwiftUI

struct ListDetailView: View {
    @EnvironmentObject private var store: TodoStore
    let listID: UUID

    @State private var newItemTitle = ""
    @FocusState private var isAddingFocused: Bool
    @State private var showCompleted = true
    @State private var appeared = false

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
                ZStack {
                    KaminTheme.black.ignoresSafeArea()
                    VStack(spacing: 12) {
                        Text("Gone.")
                            .font(KaminTheme.heroTitle)
                            .foregroundStyle(KaminTheme.yellow)
                        Text("This list no longer exists.")
                            .font(KaminTheme.body)
                            .foregroundStyle(KaminTheme.muted)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func listContent(_ list: TodoList) -> some View {
        ZStack {
            KaminTheme.black.ignoresSafeArea()

            GeometryReader { geo in
                OrganicBlob(color: KaminTheme.green.opacity(0.55), rotation: 18)
                    .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.28)
                    .offset(x: geo.size.width * 0.35, y: -20)
                OrganicBlob(color: list.color.opacity(0.22), rotation: -24)
                    .frame(width: geo.size.width * 0.55, height: geo.size.height * 0.22)
                    .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.15)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(list.name)
                                .font(KaminTheme.heroTitle)
                                .foregroundStyle(KaminTheme.yellow)
                                .minimumScaleFactor(0.55)
                                .lineLimit(2)

                            Text("\(incompleteItems.count) OPEN  ·  \(completedItems.count) DONE")
                                .font(KaminTheme.meta)
                                .foregroundStyle(KaminTheme.muted)
                                .tracking(1.2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 12, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                    }

                    Section {
                        ForEach(incompleteItems) { item in
                            TodoRowView(item: item, accent: list.color) {
                                store.toggleItem(item, in: list)
                            } onTitleChange: { title in
                                store.updateItemTitle(item, in: list, to: title)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(KaminTheme.hairline)
                        }
                        .onDelete { offsets in
                            let items = incompleteItems
                            for index in offsets {
                                store.deleteItem(items[index], in: list)
                            }
                        }

                        HStack(spacing: 14) {
                            Image(systemName: "plus")
                                .font(.body.weight(.bold))
                                .foregroundStyle(KaminTheme.yellow)
                                .frame(width: 22, height: 22)

                            TextField("New reminder", text: $newItemTitle)
                                .font(KaminTheme.body)
                                .foregroundStyle(.white)
                                .tint(KaminTheme.yellow)
                                .focused($isAddingFocused)
                                .submitLabel(.done)
                                .onSubmit(addItem)
                        }
                        .padding(.vertical, 8)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    if !completedItems.isEmpty {
                        Section {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    showCompleted.toggle()
                                }
                            } label: {
                                HStack {
                                    Text("COMPLETED")
                                        .font(KaminTheme.sectionLabel)
                                        .foregroundStyle(KaminTheme.yellow)
                                        .tracking(1.5)
                                    Spacer()
                                    Text("\(completedItems.count)")
                                        .font(KaminTheme.meta)
                                        .foregroundStyle(KaminTheme.muted)
                                    Image(systemName: "chevron.down")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(KaminTheme.muted)
                                        .rotationEffect(.degrees(showCompleted ? 0 : -90))
                                }
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 8, trailing: 20))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                            if showCompleted {
                                ForEach(completedItems) { item in
                                    TodoRowView(item: item, accent: list.color) {
                                        store.toggleItem(item, in: list)
                                    } onTitleChange: { title in
                                        store.updateItemTitle(item, in: list, to: title)
                                    }
                                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparatorTint(KaminTheme.hairline)
                                }
                                .onDelete { offsets in
                                    let items = completedItems
                                    for index in offsets {
                                        store.deleteItem(items[index], in: list)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                bottomBar(for: list)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
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
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.bold))
                        .foregroundStyle(KaminTheme.yellow)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(KaminTheme.yellow.opacity(0.5), lineWidth: 1))
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                appeared = true
            }
        }
    }

    private func bottomBar(for list: TodoList) -> some View {
        HStack {
            KaminPillButton(title: "New Reminder", systemImage: "plus") {
                isAddingFocused = true
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                colors: [KaminTheme.black.opacity(0), KaminTheme.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            .allowsHitTesting(false),
            alignment: .top
        )
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
        HStack(alignment: .center, spacing: 14) {
            KaminCheckbox(isDone: item.isDone, accent: accent, action: onToggle)

            TextField("Reminder", text: $draftTitle)
                .font(KaminTheme.body)
                .strikethrough(item.isDone, color: KaminTheme.muted)
                .foregroundStyle(item.isDone ? KaminTheme.muted : .white)
                .tint(KaminTheme.yellow)
                .submitLabel(.done)
                .onSubmit(commitTitle)
        }
        .padding(.vertical, 4)
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
