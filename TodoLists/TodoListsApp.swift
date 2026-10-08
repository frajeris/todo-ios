import SwiftUI

@main
struct TodoListsApp: App {
    @StateObject private var store = TodoStore()

    var body: some Scene {
        WindowGroup {
            ListsView()
                .environmentObject(store)
        }
    }
}
