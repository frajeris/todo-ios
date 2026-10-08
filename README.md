# Lists

A simple iPhone TODO app inspired by Apple Reminders — named lists with checkable reminders, nothing more.

## Requirements

- Xcode 15+
- iOS 17+
- iPhone only (portrait)

## Open & Run

1. Open `TodoLists.xcodeproj` in Xcode
2. Select an iPhone simulator
3. Press Run (⌘R)

## Features

- **Named lists** with color + icon
- **Reminders** you can check off
- **Completed** section (collapsible)
- Swipe to delete lists or reminders
- Search lists from the home screen
- Data saved locally with `UserDefaults`

## Structure

```
TodoLists/
├── TodoListsApp.swift    # App entry
├── Models.swift          # TodoList / TodoItem
├── TodoStore.swift       # State + persistence
├── ListsView.swift       # Home: all lists
├── ListDetailView.swift  # One list + reminders
└── NewListView.swift     # Create list sheet
```
