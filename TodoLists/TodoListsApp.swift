import SwiftUI

@main
struct TodoListsApp: App {
    @StateObject private var store = TodoStore()

    var body: some Scene {
        WindowGroup {
            ListsView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(KaminTheme.yellow)
                .background(KaminTheme.black.ignoresSafeArea())
                .overlay {
                    GrainOverlay(opacity: 0.06)
                }
        }
    }
}
