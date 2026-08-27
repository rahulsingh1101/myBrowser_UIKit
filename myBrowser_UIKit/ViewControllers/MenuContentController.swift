//
//  MenuContentController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import AppKit
import Cocoa
import SwiftUI

final class MenuContentController: NSViewController {
    var taskGridController: SwiftUIHostController<TaskGridView>!
    var pdfLibraryController: SwiftUIHostController<PDFLibraryView>!
    var taskListController: SwiftUIHostController<TaskListView>!

    private let menuContentViewModel = MenuContentViewModel()
    private let pdfLibraryViewModel = PDFLibraryViewModel()
    private let scrollViewViewModel = ScrollViewViewModel()
    private var currentMenuItem: HamburgerMenuItem = .home
    private var hasPerformedInitialOpen = false

    override func loadView() {
        let dropView = DropTargetView()
        dropView.onDropPDF = { [weak self] urls in
            urls.forEach { self?.importPDF(at: $0) }
        }
        self.view = dropView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTaskGrid()
        loadContent(isInitial: false)
    }

    private func setupTaskGrid() {
        let screenWidth = NSScreen.main?.frame.width ?? 800

        taskGridController = SwiftUIHostController(rootView: makeGridView())
        taskGridController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskGridController.view)

        pdfLibraryController = SwiftUIHostController(rootView: makePDFLibraryView())
        pdfLibraryController.view.translatesAutoresizingMaskIntoConstraints = false
        pdfLibraryController.view.isHidden = true
        view.addSubview(pdfLibraryController.view)

        taskListController = SwiftUIHostController(rootView: TaskListView(viewModel: scrollViewViewModel))
        taskListController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskListController.view)

        NSLayoutConstraint.activate([
            taskGridController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            taskGridController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            taskGridController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            taskGridController.view.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(screenWidth/3))
        ])

        NSLayoutConstraint.activate([
            pdfLibraryController.view.topAnchor.constraint(equalTo: taskGridController.view.topAnchor),
            pdfLibraryController.view.leadingAnchor.constraint(equalTo: taskGridController.view.leadingAnchor),
            pdfLibraryController.view.trailingAnchor.constraint(equalTo: taskGridController.view.trailingAnchor),
            pdfLibraryController.view.bottomAnchor.constraint(equalTo: taskGridController.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            taskListController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            taskListController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            taskListController.view.leadingAnchor.constraint(equalTo: taskGridController.view.trailingAnchor, constant: 0),
            taskListController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            taskListController.view.widthAnchor.constraint(equalToConstant: screenWidth/3)
        ])
    }

    private func makeGridView() -> TaskGridView {
        TaskGridView(
            viewModel: menuContentViewModel,
            onOpen: { [weak self] item in self?.open(item) },
            onAdd: { [weak self] in self?.presentAddItemPrompt() },
            onDelete: currentMenuItem == .home ? { [weak self] item in self?.confirmDelete(item) } : nil
        )
    }

    private func makePDFLibraryView() -> PDFLibraryView {
        PDFLibraryView(
            viewModel: pdfLibraryViewModel,
            onOpen: { [weak self] item in self?.openPDF(item) },
            onAdd: { [weak self] in self?.presentImportPDFPanel() },
            onDelete: { [weak self] item in self?.confirmDeletePDF(item) }
        )
    }

    func select(_ menuItem: HamburgerMenuItem) {
        guard menuItem != currentMenuItem else { return }
        currentMenuItem = menuItem
        taskGridController.view.isHidden = menuItem == .pdfLibrary
        pdfLibraryController.view.isHidden = menuItem != .pdfLibrary
        if menuItem != .pdfLibrary {
            taskGridController.updateRootView(makeGridView())
        }
        loadContent(isInitial: false)
    }

    private func loadContent(isInitial: Bool) {
        let menuItem = currentMenuItem
        if menuItem == .pdfLibrary {
            Task { await pdfLibraryViewModel.load() }
            return
        }
        Task {
            await menuContentViewModel.load(menuItem: menuItem)
            if isInitial { openInitialItemIfNeeded() }
        }
        if currentMenuItem == .home {
            Task { await scrollViewViewModel.load() }
        }
    }

    private func openPDF(_ item: PDFLibraryItem) {
        let appDelegate = NSApplication.shared.delegate as? AppDelegate
        guard let windowFactory = appDelegate?.windowFactory else { return }
        let reader = windowFactory.create(windowType: .reader(item))
        reader.showWindoww(self)
    }

    private func presentImportPDFPanel() {
        guard let window = view.window else { return }
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.importPDF(at: url)
        }
    }

    /// Must be called synchronously from the callback that granted access to `url` (an NSOpenPanel
    /// completion handler or a drag-and-drop callback) — see the note on `PDFLibraryViewModel.importItem`.
    private func importPDF(at url: URL) {
        let title = url.deletingPathExtension().lastPathComponent
        let bookmarkData: Data
        do {
            bookmarkData = try PDFBookmark.makeData(for: url)
        } catch {
            showAlert(for: error)
            return
        }
        Task {
            do {
                try await pdfLibraryViewModel.importItem(title: title, bookmarkData: bookmarkData)
            } catch {
                showAlert(for: error)
            }
        }
    }

    private func confirmDeletePDF(_ item: PDFLibraryItem) {
        guard let window = view.window else { return }
        let alert = NSAlert()
        alert.messageText = "Delete \"\(item.title)\"?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")

        alert.beginSheetModal(for: window) { [weak self] response in
            guard response == .alertFirstButtonReturn else { return }
            self?.deletePDF(item)
        }
    }

    private func deletePDF(_ item: PDFLibraryItem) {
        Task {
            do {
                try await pdfLibraryViewModel.delete(item)
            } catch {
                showAlert(for: error)
            }
        }
    }

    private func openInitialItemIfNeeded() {
        guard !hasPerformedInitialOpen else { return }
        hasPerformedInitialOpen = true
        if let kgsItem = menuContentViewModel.items.first(where: { $0.title == "KGS" }) {
            open(kgsItem)
        }
    }

    private func open(_ item: ItemModel) {
        let appDelegate = NSApplication.shared.delegate as? AppDelegate
        guard let windowFactory = appDelegate?.windowFactory else { return }
        let browser = windowFactory.create(windowType: .browser(item.url))
        browser.showWindoww(self)
    }

    private func presentAddItemPrompt() {
        let alert = NSAlert()
        alert.messageText = "Add Website"
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")

        let titleField = NSTextField(string: "")
        titleField.placeholderString = "Title"
        let subtitleField = NSTextField(string: "")
        subtitleField.placeholderString = "Subtitle"
        let urlField = NSTextField(string: "")
        urlField.placeholderString = "URL"

        let stack = NSStackView(views: [titleField, subtitleField, urlField])
        stack.orientation = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 90))
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        [titleField, subtitleField, urlField].forEach {
            $0.widthAnchor.constraint(equalToConstant: 260).isActive = true
        }

        alert.accessoryView = container

        guard let window = view.window else { return }
        alert.beginSheetModal(for: window) { [weak self] response in
            guard response == .alertFirstButtonReturn else { return }
            let newItem = ItemModel(
                title: titleField.stringValue,
                subtitle: subtitleField.stringValue,
                url: urlField.stringValue
            )
            self?.addItem(newItem)
        }
    }

    private func addItem(_ item: ItemModel) {
        let menuItem = currentMenuItem
        Task {
            do {
                try await menuContentViewModel.add(item, menuItem: menuItem)
            } catch {
                showAlert(for: error)
            }
        }
    }

    private func confirmDelete(_ item: ItemModel) {
        guard let window = view.window else { return }
        let alert = NSAlert()
        alert.messageText = "Delete \"\(item.title)\"?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")

        alert.beginSheetModal(for: window) { [weak self] response in
            guard response == .alertFirstButtonReturn else { return }
            self?.deleteItem(item)
        }
    }

    private func deleteItem(_ item: ItemModel) {
        let menuItem = currentMenuItem
        Task {
            do {
                try await menuContentViewModel.delete(item, menuItem: menuItem)
            } catch {
                showAlert(for: error)
            }
        }
    }

    private func showAlert(for error: Error, in window: NSWindow? = nil) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "An Error Occurred"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            if let window {
                alert.beginSheetModal(for: window)
            } else {
                alert.runModal()
            }
        }
    }
}

/// Accepts dropped PDF files anywhere over the content area and forwards their URLs for import.
private final class DropTargetView: NSView {
    var onDropPDF: (([URL]) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        pdfURLs(from: sender).isEmpty ? [] : .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = pdfURLs(from: sender)
        guard !urls.isEmpty else { return false }
        onDropPDF?(urls)
        return true
    }

    private func pdfURLs(from sender: NSDraggingInfo) -> [URL] {
        let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] ?? []
        return urls.filter { $0.pathExtension.lowercased() == "pdf" }
    }
}
