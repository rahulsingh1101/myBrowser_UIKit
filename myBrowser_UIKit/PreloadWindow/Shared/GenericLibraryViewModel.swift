//
//  GenericLibraryViewModel.swift
//  myBrowser_UIKit
//

import Foundation

/// The repository is passed per-call rather than held, since one instance may back multiple repositories (e.g. Home vs. Focus Music).
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
