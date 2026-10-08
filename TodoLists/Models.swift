import Foundation
import SwiftUI

struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool = false
    var createdAt: Date = Date()
}

struct TodoList: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var colorName: String
    var iconName: String
    var items: [TodoItem] = []
    var createdAt: Date = Date()

    var color: Color {
        Color.listColor(named: colorName)
    }

    var incompleteCount: Int {
        items.filter { !$0.isDone }.count
    }
}

extension Color {
    static let listPalette: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("red", .red),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("purple", .purple),
        ("pink", .pink),
        ("teal", .teal),
        ("indigo", .indigo),
        ("brown", .brown),
    ]

    static func listColor(named name: String) -> Color {
        listPalette.first { $0.name == name }?.color ?? .blue
    }
}
