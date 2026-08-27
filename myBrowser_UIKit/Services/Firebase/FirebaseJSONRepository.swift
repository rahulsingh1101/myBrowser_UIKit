//
//  FirebaseJSONRepository.swift
//  myBrowser_UIKit
//

import Foundation

final class FirebaseJSONRepository<Model: Codable> {
    private let path: String
    private let bundleFallbackResource: String?
    private let store: RealtimeDatabaseStore

    init(path: String, bundleFallbackResource: String? = nil, store: RealtimeDatabaseStore = .shared) {
        self.path = path
        self.bundleFallbackResource = bundleFallbackResource
        self.store = store
    }

    func load() async throws -> Model {
        do {
            return try await store.read(at: path, as: Model.self)
        } catch {
            guard let bundleFallbackResource else { throw error }
            return try loadBundleFallback(bundleFallbackResource)
        }
    }

    func save(_ model: Model) async throws {
        try await store.write(model, at: path)
    }

    private func loadBundleFallback(_ resource: String) throws -> Model {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            throw RealtimeDatabaseError.noData
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Model.self, from: data)
    }
}

extension FirebaseJSONRepository where Model == [ItemModel] {
    static func preloadWebsites() -> FirebaseJSONRepository<[ItemModel]> {
        FirebaseJSONRepository(path: "preloadWebsites", bundleFallbackResource: "PreloadWebsitesController")
    }

    static func focusMusic() -> FirebaseJSONRepository<[ItemModel]> {
        FirebaseJSONRepository(path: "focusMusic")
    }
}

extension FirebaseJSONRepository where Model == ListViewModel {
    static func scrollViewData() -> FirebaseJSONRepository<ListViewModel> {
        FirebaseJSONRepository(path: "scrollViewData", bundleFallbackResource: "scrollViewData")
    }
}

extension FirebaseJSONRepository where Model == [PDFLibraryItem] {
    static func pdfLibrary() -> FirebaseJSONRepository<[PDFLibraryItem]> {
        FirebaseJSONRepository(path: "pdfLibrary")
    }
}

// MARK: - Array element operations
//
// All Firebase-touching operations on an array-shaped `Model` — load/save whole-array via the
// members above, plus add/delete/update a single element — live in this one file, so
// `GenericLibraryViewModel` never needs to know how a mutation is persisted, only that it is.
extension FirebaseJSONRepository {
    /// Loads the current array, appends `item`, saves, and returns the saved array.
    @discardableResult
    func addElement<Item: Identifiable>(_ item: Item) async throws -> [Item] where Model == [Item] {
        let updated = try await load() + [item]
        try await save(updated)
        return updated
    }

    /// Loads the current array, removes the element matching `id`, saves, and returns the saved array.
    @discardableResult
    func deleteElement<Item: Identifiable>(id: Item.ID) async throws -> [Item] where Model == [Item] {
        let updated = try await load().filter { $0.id != id }
        try await save(updated)
        return updated
    }

    /// Loads the current array, mutates the element matching `id` in place, saves, and returns the
    /// saved array. A no-op (returns the array unmodified) if no element matches `id`.
    @discardableResult
    func updateElement<Item: Identifiable>(id: Item.ID, mutate: (inout Item) -> Void) async throws -> [Item] where Model == [Item] {
        var items = try await load()
        guard let index = items.firstIndex(where: { $0.id == id }) else { return items }
        mutate(&items[index])
        try await save(items)
        return items
    }
}
