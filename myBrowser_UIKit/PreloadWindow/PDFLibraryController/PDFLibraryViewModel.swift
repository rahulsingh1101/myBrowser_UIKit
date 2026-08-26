//
//  PDFLibraryViewModel.swift
//  myBrowser_UIKit
//

import Foundation

@MainActor
final class PDFLibraryViewModel: ObservableObject {
    @Published var items: [PDFLibraryItem] = []

    private let repository = FirebaseJSONRepository<[PDFLibraryItem]>.pdfLibrary()

    func load() async {
        do {
            items = try await repository.load()
        } catch {
            items = []
        }
    }

    /// `bookmarkData` must be created synchronously at the point the file URL is granted (an NSOpenPanel
    /// completion handler or a drag-and-drop callback) — deferring it past an actor hop / `Task` can outlive
    /// the sandbox's grant for that URL and fail with "Operation not permitted".
    func importItem(title: String, bookmarkData: Data) async throws {
        let newItem = PDFLibraryItem(
            id: UUID().uuidString,
            title: title,
            bookmarkData: bookmarkData,
            lastReadPage: 0,
            dateAdded: Date().timeIntervalSince1970
        )
        try await repository.save(items + [newItem])
        await load()
    }

    func delete(_ item: PDFLibraryItem) async throws {
        try await repository.save(items.filter { $0.id != item.id })
        await load()
    }
}
