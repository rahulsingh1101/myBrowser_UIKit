//
//  MenuContentViewModel.swift
//  myBrowser_UIKit
//

import Foundation

@MainActor
final class MenuContentViewModel: ObservableObject {
    @Published var items: [ItemModel] = []

    func load(section: RepositoryBackedItemModel) async {
        do {
            items = try await section.repository.load()
        } catch {
            items = []
        }
    }

    func add(_ item: ItemModel, section: RepositoryBackedItemModel) async throws {
        try await section.repository.save(items + [item])
        await load(section: section)
    }

    func delete(_ item: ItemModel, section: RepositoryBackedItemModel) async throws {
        try await section.repository.save(items.filter { $0.id != item.id })
        await load(section: section)
    }
}
