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
    var taskListController: SwiftUIHostController<TaskListView>!

    private let taskGridViewModel = TaskGridViewModel()
    private let focusMusicViewModel = TaskGridViewModel()
    private let scrollViewViewModel = ScrollViewViewModel()
    private var currentMenuItem: HamburgerMenuItem = .home
    private var hasPerformedInitialOpen = false

    private var activeGridViewModel: TaskGridViewModel {
        switch currentMenuItem {
        case .home: return taskGridViewModel
        case .focusMusic: return focusMusicViewModel
        }
    }

    var items: [ItemModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTaskGrid()
        loadItems(isInitial: false)
    }

    private func setupTaskGrid() {
        let screenWidth = NSScreen.main?.frame.width ?? 800

        taskGridController = SwiftUIHostController(rootView: makeGridView(viewModel: activeGridViewModel))
        taskGridController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskGridController.view)

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
            taskListController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            taskListController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            taskListController.view.leadingAnchor.constraint(equalTo: taskGridController.view.trailingAnchor, constant: 0),
            taskListController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            taskListController.view.widthAnchor.constraint(equalToConstant: screenWidth/3)
        ])
    }

    private func makeGridView(viewModel: TaskGridViewModel) -> TaskGridView {
        TaskGridView(
            viewModel: viewModel,
            onOpen: { [weak self] item in self?.open(item) },
            onAdd: { [weak self] in self?.presentAddItemPrompt() },
            onDelete: currentMenuItem == .home ? { [weak self] item in self?.confirmDelete(item) } : nil
        )
    }

    func select(_ menuItem: HamburgerMenuItem) {
        guard menuItem != currentMenuItem else { return }
        currentMenuItem = menuItem
        taskGridController.updateRootView(makeGridView(viewModel: activeGridViewModel))
        loadItems(isInitial: false)
    }

    private func loadItems(isInitial: Bool) {
        let gridViewModel = activeGridViewModel
        Task {
            do {
                let loaded = try await currentMenuItem.repository.load()
                await MainActor.run {
                    self.items = loaded
                    gridViewModel.items = loaded
                    if isInitial { self.openInitialItemIfNeeded() }
                }
            } catch {
                await MainActor.run {
                    self.items = []
                    gridViewModel.items = []
                }
            }
        }
        if currentMenuItem == .home {
            loadListData()
        }
    }

    private func loadListData() {
        Task {
            do {
                let loaded = try await FirebaseJSONRepository.scrollViewData().load()
                await MainActor.run { self.scrollViewViewModel.data = loaded }
            } catch {
                await MainActor.run { self.scrollViewViewModel.data = .defaultValue }
            }
        }
    }

    private func openInitialItemIfNeeded() {
        guard !hasPerformedInitialOpen else { return }
        hasPerformedInitialOpen = true
        if let kgsItem = items.first(where: { $0.title == "KGS" }) {
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
        Task {
            do {
                try await currentMenuItem.repository.save(items + [item])
                loadItems(isInitial: false)
            } catch {
                await MainActor.run { self.showAlert(for: error) }
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
        Task {
            do {
                try await currentMenuItem.repository.save(items.filter { $0.id != item.id })
                loadItems(isInitial: false)
            } catch {
                await MainActor.run { self.showAlert(for: error) }
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
                alert.beginSheetModal(for: window) { response in
                    print("debug :: response:: \(response)")
                }
            } else {
                alert.runModal()
            }
        }
    }
}
