//
//  HomeController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import AppKit
import Cocoa
import SwiftUI

final class HomeController: NSViewController {
    var taskGridController: SwiftUIHostController<TaskGridView>!
    var taskListController: SwiftUIHostController<TaskListView>!

    private let taskGridViewModel = TaskGridViewModel()
    private let repository = FirebaseJSONRepository<[ItemModel]>.preloadWebsites()
    private var hasPerformedInitialOpen = false

    var items: [ItemModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTaskGrid()
        loadItems(isInitial: false)
    }

    private func setupTaskGrid() {
        let screenWidth = NSScreen.main?.frame.width ?? 800

        taskGridController = SwiftUIHostController(
            rootView: TaskGridView(
                viewModel: taskGridViewModel,
                onOpen: { [weak self] item in self?.open(item) },
                onAdd: { [weak self] in self?.presentAddItemPrompt() }
            )
        )
        taskGridController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskGridController.view)

        taskListController = SwiftUIHostController(rootView: TaskListView())
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

    private func loadItems(isInitial: Bool) {
        Task {
            do {
                let loaded = try await repository.load()
                await MainActor.run {
                    self.items = loaded
                    self.taskGridViewModel.items = loaded
                    if isInitial { self.openInitialItemIfNeeded() }
                }
            } catch {
                await MainActor.run { self.showAlert(for: error) }
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
                try await repository.save(items + [item])
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
