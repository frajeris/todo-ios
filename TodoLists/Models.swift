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
        ("yellow", Color(red: 1.0, green: 1.0, blue: 0.314)),
        ("burgundy", Color(red: 0.55, green: 0.16, blue: 0.26)),
        ("forest", Color(red: 0.20, green: 0.38, blue: 0.24)),
        ("magenta", Color(red: 0.85, green: 0.22, blue: 0.55)),
        ("teal", Color(red: 0.22, green: 0.55, blue: 0.55)),
        ("charcoal", Color(red: 0.42, green: 0.42, blue: 0.40)),
        ("ochre", Color(red: 0.78, green: 0.52, blue: 0.18)),
        ("cream", Color(red: 0.91, green: 0.90, blue: 0.86)),
        ("brick", Color(red: 0.70, green: 0.28, blue: 0.22)),
        ("ink", Color(red: 0.18, green: 0.22, blue: 0.35)),
    ]

    static func listColor(named name: String) -> Color {
        if let match = listPalette.first(where: { $0.name == name }) {
            return match.color
        }
        // Legacy Apple palette names from older saves
        let legacy: [String: Color] = [
            "blue": listPalette[4].color,
            "red": listPalette[8].color,
            "orange": listPalette[6].color,
            "green": listPalette[2].color,
            "purple": listPalette[3].color,
            "pink": listPalette[3].color,
            "indigo": listPalette[9].color,
            "brown": listPalette[5].color,
        ]
        return legacy[name] ?? listPalette[0].color
    }
}
