import SwiftUI

struct ListsView: View {
    @EnvironmentObject private var store: TodoStore
    @State private var showingNewList = false
    @State private var searchText = ""

    private var filteredLists: [TodoList] {
        if searchText.isEmpty { return store.lists }
        return store.lists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(filteredLists) { list in
                        NavigationLink(value: list.id) {
                            ListRowView(list: list)
                        }
                    }
                    .onDelete(perform: store.deleteLists)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Lists")
            .navigationDestination(for: UUID.self) { listID in
                if let list = store.lists.first(where: { $0.id == listID }) {
                    ListDetailView(listID: list.id)
                }
            }
            .searchable(text: $searchText, prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button {
                        showingNewList = true
                    } label: {
                        Label("Add List", systemImage: "plus.circle.fill")
                            .font(.body.weight(.semibold))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.bar)
            }
            .sheet(isPresented: $showingNewList) {
                NewListView()
            }
        }
    }
}

struct ListRowView: View {
    let list: TodoList

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: list.iconName)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(list.color, in: Circle())

            Text(list.name)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            Text("\(list.incompleteCount)")
                .font(.body)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ListsView()
        .environmentObject(TodoStore())
}
