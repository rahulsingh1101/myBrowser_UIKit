//
//  MenuContentViewModel.swift
//  myBrowser_UIKit
//

import Foundation

@MainActor
final class MenuContentViewModel: ObservableObject {
    @Published var items: [ItemModel] = []

    func load(menuItem: HamburgerMenuItem) async {
        do {
            items = try await menuItem.repository.load()
        } catch {
            items = []
        }
    }

    func add(_ item: ItemModel, menuItem: HamburgerMenuItem) async throws {
        try await menuItem.repository.save(items + [item])
        await load(menuItem: menuItem)
    }

    func delete(_ item: ItemModel, menuItem: HamburgerMenuItem) async throws {
        try await menuItem.repository.save(items.filter { $0.id != item.id })
        await load(menuItem: menuItem)
    }
}
