//
//  PDFReaderViewController.swift
//  myBrowser_UIKit
//

import Cocoa
import PDFKit

final class PDFReaderViewController: NSViewController {
    private let pdfView = PDFView()
    private var item: PDFLibraryItem!
    private var resolvedURL: URL?
    private var didStartAccessingSecurityScope = false
    private var currentPageIndex: Int = 0

    override func loadView() {
        self.view = NSView()

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        view.addSubview(pdfView)

        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func load(item: PDFLibraryItem) {
        self.item = item
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(pageDidChange), name: .PDFViewPageChanged, object: pdfView)
        openDocument()
    }

    private func openDocument() {
        guard let url = PDFBookmark.resolve(item.bookmarkData) else {
            showLoadError()
            return
        }
        resolvedURL = url
        // A bookmark resolved without an active security scope (e.g. one created without
        // `.withSecurityScope` support) still yields a usable file URL — just try to open it.
        didStartAccessingSecurityScope = url.startAccessingSecurityScopedResource()

        guard let document = PDFDocument(url: url) else {
            showLoadError()
            return
        }
        pdfView.document = document
        currentPageIndex = item.lastReadPage
        if item.lastReadPage > 0, let page = document.page(at: item.lastReadPage) {
            pdfView.go(to: page)
        }
    }

    private func showLoadError() {
        let alert = NSAlert()
        alert.messageText = "Couldn't Open PDF"
        alert.informativeText = "\"\(item.title)\" may have been moved, renamed, or deleted."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func pageDidChange() {
        guard let document = pdfView.document, let page = pdfView.currentPage else { return }
        currentPageIndex = document.index(for: page)
    }

    func persistCurrentPage() async {
        if didStartAccessingSecurityScope {
            resolvedURL?.stopAccessingSecurityScopedResource()
        }
        guard let item else { return }
        let pageIndex = currentPageIndex
        try? await FirebaseJSONRepository<[PDFLibraryItem]>.pdfLibrary()
            .updateElement(id: item.id) { $0.lastReadPage = pageIndex }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
