//
//  GenericLibraryViewModel.swift
//  myBrowser_UIKit
//

import Foundation

/// Backs any grid pane whose items are a `Codable & Identifiable` array persisted as a whole via
/// `FirebaseJSONRepository`. The repository is passed per-call rather than held, since callers such
/// as `MenuContentController` may need to load/save against a different repository per section
/// (e.g. Home vs. Focus Music) using the same `Item` type.
@MainActor
final class GenericLibraryViewModel<Item: Codable & Identifiable>: ObservableObject {
    @Published var items: [Item] = []

    func load(from repository: FirebaseJSONRepository<[Item]>) async {
        do {
            items = try await repository.load()
        } catch {
            items = []
        }
    }

    func add(_ item: Item, to repository: FirebaseJSONRepository<[Item]>) async throws {
        items = try await repository.addElement(item)
    }

    func delete(_ item: Item, from repository: FirebaseJSONRepository<[Item]>) async throws {
        items = try await repository.deleteElement(id: item.id)
    }
}
