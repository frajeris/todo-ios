import SwiftUI

struct ListsView: View {
    @EnvironmentObject private var store: TodoStore
    @State private var showingNewList = false
    @State private var searchText = ""
    @State private var isEditing = false
    @State private var appeared = false

    private var filteredLists: [TodoList] {
        if searchText.isEmpty { return store.lists }
        return store.lists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KaminTheme.black.ignoresSafeArea()

                GeometryReader { geo in
                    OrganicBlob(color: KaminTheme.green.opacity(0.85), rotation: -12)
                        .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.42)
                        .offset(x: -geo.size.width * 0.18, y: -40)
                    OrganicBlob(color: KaminTheme.burgundy.opacity(0.55), rotation: 28)
                        .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.32)
                        .offset(x: geo.size.width * 0.42, y: geo.size.height * 0.08)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)

                VStack(spacing: 0) {
                    List {
                        Section {
                            hero
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 18)

                            KaminSearchField(text: $searchText)
                                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 8, trailing: 20))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }

                        Section {
                            if filteredLists.isEmpty {
                                emptyState
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            } else {
                                ForEach(filteredLists) { list in
                                    NavigationLink(value: list.id) {
                                        ListRowView(list: list)
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparatorTint(KaminTheme.hairline)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            store.deleteList(list)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                                .onDelete(perform: deleteFilteredLists)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, .constant(isEditing ? .active : .inactive))

                    bottomBar
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing.toggle()
                        }
                    }
                    .font(KaminTheme.sectionLabel)
                    .foregroundStyle(KaminTheme.yellow)
                    .textCase(.uppercase)
                    .tracking(1)
                }
            }
            .navigationDestination(for: UUID.self) { listID in
                if store.lists.contains(where: { $0.id == listID }) {
                    ListDetailView(listID: listID)
                }
            }
            .sheet(isPresented: $showingNewList) {
                NewListView()
                    .presentationDetents([.large])
                    .presentationBackground(KaminTheme.black)
            }
            .onAppear {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    appeared = true
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LISTS")
                .font(KaminTheme.heroTitle)
                .foregroundStyle(KaminTheme.yellow)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text("\(store.lists.count) COLLECTIONS")
                .font(KaminTheme.meta)
                .foregroundStyle(KaminTheme.muted)
                .tracking(1.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text(searchText.isEmpty ? "Nothing here yet." : "No matches.")
                .font(KaminTheme.displayTitle)
                .foregroundStyle(KaminTheme.yellow.opacity(0.9))
                .multilineTextAlignment(.center)
            Text(searchText.isEmpty ? "Start a list and make it yours." : "Try another search.")
                .font(KaminTheme.body)
                .foregroundStyle(KaminTheme.muted)
        }
        .padding(.horizontal, 32)
    }

    private func deleteFilteredLists(at offsets: IndexSet) {
        let ids = offsets.map { filteredLists[$0].id }
        for id in ids {
            if let list = store.lists.first(where: { $0.id == id }) {
                store.deleteList(list)
            }
        }
    }

    private var bottomBar: some View {
        HStack {
            Spacer()
            KaminPillButton(title: "Add List", systemImage: "plus") {
                showingNewList = true
            }
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
}

struct ListRowView: View {
    let list: TodoList

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: list.iconName)
                .font(.body.weight(.semibold))
                .foregroundStyle(.black)
                .frame(width: 36, height: 36)
                .background(list.color, in: RoundedRectangle(cornerRadius: 4, style: .continuous))

            Text(list.name)
                .font(KaminTheme.body.weight(.medium))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text("\(list.incompleteCount)")
                .font(KaminTheme.meta)
                .foregroundStyle(KaminTheme.yellow.opacity(0.85))
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    ListsView()
        .environmentObject(TodoStore())
        .preferredColorScheme(.dark)
}
