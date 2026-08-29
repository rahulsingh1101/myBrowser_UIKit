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
    var taskGridController: SwiftUIHostController<LibraryGridView<ItemModel>>!
    var pdfLibraryController: SwiftUIHostController<LibraryGridView<PDFLibraryItem>>!
    var taskListController: SwiftUIHostController<TaskListView>!

    private let menuContentViewModel = GenericLibraryViewModel<ItemModel>()
    private let pdfLibraryViewModel = GenericLibraryViewModel<PDFLibraryItem>()
    private let scrollViewViewModel = ScrollViewViewModel()
    private var currentMenuItem: HamburgerMenuItem = .home
    private var coordinator: LibraryCoordinator!

    init(windowCreating: WindowCreating) {
        super.init(nibName: nil, bundle: nil)
        coordinator = LibraryCoordinator(
            windowCreating: windowCreating,
            alertPresenting: AlertPresenter(),
            menuContentViewModel: menuContentViewModel,
            pdfLibraryViewModel: pdfLibraryViewModel
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let dropView = DropTargetView()
        dropView.onDropPDF = { [weak self] urls in
            urls.forEach { self?.coordinator.importPDF(at: $0) }
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

    private func makeGridView() -> LibraryGridView<ItemModel> {
        LibraryGridView(
            viewModel: menuContentViewModel,
            subtitle: { $0.subtitle },
            onOpen: { [weak self] item in self?.coordinator.open(item) },
            onAdd: { [weak self] in self?.presentAddItemPrompt() },
            onDelete: { [weak self] item in self?.confirmDeleteItem(item) },
            onCopyURL: { item in
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(item.url, forType: .string)
            }
        )
    }

    private func makePDFLibraryView() -> LibraryGridView<PDFLibraryItem> {
        LibraryGridView(
            viewModel: pdfLibraryViewModel,
            subtitle: { $0.lastReadPage > 0 ? "Last read: page \($0.lastReadPage + 1)" : "Not started" },
            onOpen: { [weak self] item in self?.coordinator.openPDF(item) },
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
            Task { await pdfLibraryViewModel.load(from: .pdfLibrary()) }
            return
        }
        guard let repository = menuItem.itemModelRepository else { return }
        Task {
            await menuContentViewModel.load(from: repository)
            if isInitial { coordinator.openInitialItemIfNeeded() }
        }
        if currentMenuItem == .home {
            Task { await scrollViewViewModel.load() }
        }
    }

    private func presentImportPDFPanel() {
        guard let window = view.window else { return }
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.coordinator.importPDF(at: url)
        }
    }

    private func confirmDeletePDF(_ item: PDFLibraryItem) {
        guard let window = view.window else { return }
        coordinator.confirmDeletePDF(item, in: window)
    }

    private func presentAddItemPrompt() {
        guard let window = view.window, let repository = currentMenuItem.itemModelRepository else { return }
        coordinator.presentAddItemPrompt(in: window, to: repository)
    }

    private func confirmDeleteItem(_ item: ItemModel) {
        guard let window = view.window, let repository = currentMenuItem.itemModelRepository else { return }
        coordinator.confirmDelete(item, in: window, from: repository)
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
