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
    private var gridPane: GridMenuPane<ItemModel>!
    private var pdfPane: PDFLibraryMenuPane!
    var taskListController: SwiftUIHostController<TaskListView>!

    private let menuContentViewModel = GenericLibraryViewModel<ItemModel>()
    private let pdfLibraryViewModel = GenericLibraryViewModel<PDFLibraryItem>()
    private let scrollViewViewModel = ScrollViewViewModel()
    private(set) var currentMenuItem: HamburgerMenuItem = .home
    private var activePane: MenuPane!
    private var coordinator: LibraryCoordinator!

    /// Exhaustive `switch`: a new `HamburgerMenuItem` case fails to compile until it's routed here.
    private func pane(for item: HamburgerMenuItem) -> MenuPane {
        switch item {
        case .home, .focusMusic: return gridPane
        case .pdfLibrary: return pdfPane
        }
    }

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

        gridPane = GridMenuPane(
            viewModel: menuContentViewModel,
            repositories: [.home: .preloadWebsites(), .focusMusic: .focusMusic()],
            subtitle: { $0.subtitle },
            onOpen: { [weak self] item in self?.coordinator.open(item) },
            onAdd: { [weak self] in self?.presentAddItemPrompt() },
            onDelete: { [weak self] item in self?.confirmDeleteItem(item) },
            onCopyURL: { item in
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(item.url, forType: .string)
            },
            onEdit: { [weak self] item in self?.presentEditItemPrompt(item) }
        )
        pdfPane = PDFLibraryMenuPane(
            viewModel: pdfLibraryViewModel,
            onOpen: { [weak self] item in self?.coordinator.openPDF(item) },
            onAdd: { [weak self] in self?.presentImportPDFPanel() },
            onDelete: { [weak self] item in self?.confirmDeletePDF(item) }
        )
        activePane = pane(for: currentMenuItem)

        gridPane.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridPane.view)

        pdfPane.view.translatesAutoresizingMaskIntoConstraints = false
        pdfPane.view.isHidden = pdfPane !== activePane
        view.addSubview(pdfPane.view)

        taskListController = SwiftUIHostController(rootView: TaskListView(viewModel: scrollViewViewModel))
        taskListController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskListController.view)

        NSLayoutConstraint.activate([
            gridPane.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            gridPane.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            gridPane.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            gridPane.view.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(screenWidth/3))
        ])

        NSLayoutConstraint.activate([
            pdfPane.view.topAnchor.constraint(equalTo: gridPane.view.topAnchor),
            pdfPane.view.leadingAnchor.constraint(equalTo: gridPane.view.leadingAnchor),
            pdfPane.view.trailingAnchor.constraint(equalTo: gridPane.view.trailingAnchor),
            pdfPane.view.bottomAnchor.constraint(equalTo: gridPane.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            taskListController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            taskListController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            taskListController.view.leadingAnchor.constraint(equalTo: gridPane.view.trailingAnchor, constant: 0),
            taskListController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            taskListController.view.widthAnchor.constraint(equalToConstant: screenWidth/3)
        ])
    }

    func select(_ menuItem: HamburgerMenuItem) {
        guard menuItem != currentMenuItem else { return }
        currentMenuItem = menuItem
        let newPane = pane(for: menuItem)
        if newPane !== activePane {
            activePane.view.isHidden = true
            newPane.view.isHidden = false
            activePane = newPane
        }
        loadContent(isInitial: false)
    }

    private func loadContent(isInitial: Bool) {
        let menuItem = currentMenuItem
        let pane = activePane!
        Task {
            await pane.load(for: menuItem)
            if isInitial { coordinator.openInitialItemIfNeeded() }
        }
        if menuItem == .home {
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
        guard let window = view.window, let repository = gridPane.repository(for: currentMenuItem) else { return }
        coordinator.presentAddItemPrompt(in: window, to: repository)
    }

    private func presentEditItemPrompt(_ item: ItemModel) {
        guard let window = view.window, let repository = gridPane.repository(for: currentMenuItem) else { return }
        coordinator.presentEditItemPrompt(item, in: window, in: repository)
    }

    private func confirmDeleteItem(_ item: ItemModel) {
        guard let window = view.window, let repository = gridPane.repository(for: currentMenuItem) else { return }
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
