//
//  LibraryCoordinator.swift
//  myBrowser_UIKit
//

import AppKit

@MainActor
final class LibraryCoordinator {
    private let windowCreating: WindowCreating
    private let menuContentViewModel: GenericLibraryViewModel<ItemModel>
    private let pdfLibraryViewModel: GenericLibraryViewModel<PDFLibraryItem>
    private let presentError: (Error) -> Void
    private var hasPerformedInitialOpen = false

    init(
        windowCreating: WindowCreating,
        menuContentViewModel: GenericLibraryViewModel<ItemModel>,
        pdfLibraryViewModel: GenericLibraryViewModel<PDFLibraryItem>,
        presentError: @escaping (Error) -> Void
    ) {
        self.windowCreating = windowCreating
        self.menuContentViewModel = menuContentViewModel
        self.pdfLibraryViewModel = pdfLibraryViewModel
        self.presentError = presentError
    }

    func open(_ item: ItemModel) {
        let browser = windowCreating.create(windowType: .browser(item.url))
        browser.presentWindow(nil)
    }

    func openPDF(_ item: PDFLibraryItem) {
        let reader = windowCreating.create(windowType: .reader(item))
        reader.presentWindow(nil)

        guard let windowController = reader as? NSWindowController,
              let window = windowController.window,
              let readerVC = windowController.contentViewController as? PDFReaderViewController else { return }

        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { [weak self] _ in
            Task {
                await readerVC.persistCurrentPage()
                await self?.pdfLibraryViewModel.load(from: .pdfLibrary())
            }
        }
    }

    func openInitialItemIfNeeded() {
        guard !hasPerformedInitialOpen else { return }
        hasPerformedInitialOpen = true
        if let kgsItem = menuContentViewModel.items.first(where: { $0.title == "KGS" }) {
            open(kgsItem)
        }
    }

    /// Must run synchronously in the callback that granted access to `url` — deferring past an actor hop can lose the sandbox grant.
    func importPDF(at url: URL) {
        let title = url.deletingPathExtension().lastPathComponent
        let bookmarkData: Data
        do {
            bookmarkData = try PDFBookmark.makeData(for: url)
        } catch {
            presentError(error)
            return
        }
        let newItem = PDFLibraryItem(
            id: UUID().uuidString,
            title: title,
            bookmarkData: bookmarkData,
            lastReadPage: 0,
            dateAdded: Date().timeIntervalSince1970
        )
        runCatchingErrors { [weak self] in
            try await self?.pdfLibraryViewModel.add(newItem, to: .pdfLibrary())
        }
    }

    func deletePDF(_ item: PDFLibraryItem) {
        runCatchingErrors { [weak self] in
            try await self?.pdfLibraryViewModel.delete(item, from: .pdfLibrary())
        }
    }

    func addItem(_ item: ItemModel, to repository: FirebaseJSONRepository<[ItemModel]>) {
        runCatchingErrors { [weak self] in
            try await self?.menuContentViewModel.add(item, to: repository)
        }
    }

    func deleteItem(_ item: ItemModel, from repository: FirebaseJSONRepository<[ItemModel]>) {
        runCatchingErrors { [weak self] in
            try await self?.menuContentViewModel.delete(item, from: repository)
        }
    }

    private func runCatchingErrors(_ operation: @escaping () async throws -> Void) {
        Task {
            do {
                try await operation()
            } catch {
                presentError(error)
            }
        }
    }
}
