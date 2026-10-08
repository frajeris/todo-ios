import Foundation
import SwiftUI

@MainActor
final class TodoStore: ObservableObject {
    @Published var lists: [TodoList] = []

    private let saveKey = "todo_lists_v1"

    init() {
        load()
        if lists.isEmpty {
            seedSampleData()
        }
    }

    // MARK: - Lists

    func addList(name: String, colorName: String, iconName: String) {
        let list = TodoList(name: name, colorName: colorName, iconName: iconName)
        lists.append(list)
        save()
    }

    func deleteLists(at offsets: IndexSet) {
        lists.remove(atOffsets: offsets)
        save()
    }

    func deleteList(_ list: TodoList) {
        lists.removeAll { $0.id == list.id }
        save()
    }

    func renameList(_ list: TodoList, to name: String) {
        guard let index = lists.firstIndex(where: { $0.id == list.id }) else { return }
        lists[index].name = name
        save()
    }

    // MARK: - Items

    func addItem(to list: TodoList, title: String) {
        guard let index = lists.firstIndex(where: { $0.id == list.id }) else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lists[index].items.insert(TodoItem(title: trimmed), at: 0)
        save()
    }

    func toggleItem(_ item: TodoItem, in list: TodoList) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }),
              let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id })
        else { return }
        lists[listIndex].items[itemIndex].isDone.toggle()
        save()
    }

    func deleteItems(at offsets: IndexSet, in list: TodoList) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }) else { return }
        lists[listIndex].items.remove(atOffsets: offsets)
        save()
    }

    func deleteItem(_ item: TodoItem, in list: TodoList) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }) else { return }
        lists[listIndex].items.removeAll { $0.id == item.id }
        save()
    }

    func updateItemTitle(_ item: TodoItem, in list: TodoList, to title: String) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }),
              let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id })
        else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lists[listIndex].items[itemIndex].title = trimmed
        save()
    }

    func clearCompleted(in list: TodoList) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }) else { return }
        lists[listIndex].items.removeAll { $0.isDone }
        save()
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(lists) else { return }
        UserDefaults.standard.set(data, forKey: saveKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([TodoList].self, from: data)
        else { return }
        lists = decoded
    }

    private func seedSampleData() {
        lists = [
            TodoList(
                name: "Reminders",
                colorName: "yellow",
                iconName: "list.bullet",
                items: [
                    TodoItem(title: "Buy groceries"),
                    TodoItem(title: "Call Mom"),
                    TodoItem(title: "Finish report", isDone: true),
                ]
            ),
            TodoList(
                name: "Groceries",
                colorName: "forest",
                iconName: "cart",
                items: [
                    TodoItem(title: "Milk"),
                    TodoItem(title: "Eggs"),
                    TodoItem(title: "Bread"),
                ]
            ),
            TodoList(
                name: "Work",
                colorName: "ochre",
                iconName: "briefcase",
                items: [
                    TodoItem(title: "Review pull request"),
                    TodoItem(title: "Schedule 1:1"),
                ]
            ),
        ]
        save()
    }
}
