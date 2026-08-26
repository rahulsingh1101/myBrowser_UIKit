//
//  FirebaseJSONRepository.swift
//  myBrowser_UIKit
//

import Foundation

final class FirebaseJSONRepository<Model: Codable> {
    private let path: String
    private let bundleFallbackResource: String
    private let store: RealtimeDatabaseStore

    init(path: String, bundleFallbackResource: String, store: RealtimeDatabaseStore = .shared) {
        self.path = path
        self.bundleFallbackResource = bundleFallbackResource
        self.store = store
    }

    func load() async throws -> Model {
        do {
            return try await store.read(at: path, as: Model.self)
        } catch {
            return try loadBundleFallback()
        }
    }

    func save(_ model: Model) async throws {
        try await store.write(model, at: path)
    }

    private func loadBundleFallback() throws -> Model {
        guard let url = Bundle.main.url(forResource: bundleFallbackResource, withExtension: "json") else {
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
}

extension FirebaseJSONRepository where Model == ListViewModel {
    static func scrollViewData() -> FirebaseJSONRepository<ListViewModel> {
        FirebaseJSONRepository(path: "scrollViewData", bundleFallbackResource: "scrollViewData")
    }
}
