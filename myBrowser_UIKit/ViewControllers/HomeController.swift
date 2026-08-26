//
//  HomeController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import AppKit
import Cocoa

final class HomeController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {
    private let taskItemIdentifier = NSUserInterfaceItemIdentifier("PreloadItem")
    private let addItemIdentifier = NSUserInterfaceItemIdentifier("AddItem")
    var collectionView: NSCollectionView!
    var taskListController: SwiftUIHostController<TaskListView>!

    private let repository = FirebaseJSONRepository<[ItemModel]>.preloadWebsites()
    private var hasPerformedInitialOpen = false

    var items: [ItemModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        loadItems(isInitial: false)
    }

    private func setupCollectionView() {
        // 1. Create ScrollView
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // 2. View Controller
        let screenWidth = NSScreen.main?.frame.width ?? 800
        taskListController = SwiftUIHostController(rootView: TaskListView())
        taskListController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskListController.view)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])

        NSLayoutConstraint.activate([
            taskListController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            taskListController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            taskListController.view.leadingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0),
            taskListController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            taskListController.view.widthAnchor.constraint(equalToConstant: screenWidth/3)
        ])

        // 2. Create CollectionView
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 300, height: 100)
        layout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10

        collectionView = NSCollectionView(frame: .zero)
        collectionView.collectionViewLayout = layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isSelectable = true
        collectionView.register(TaskCell.self, forItemWithIdentifier: taskItemIdentifier)
        collectionView.register(AddItemCell.self, forItemWithIdentifier: addItemIdentifier)

        // 3. Embed in ScrollView
        scrollView.documentView = collectionView
        collectionView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + 1
    }

    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard indexPath.item < items.count else {
            let item = collectionView.makeItem(withIdentifier: addItemIdentifier, for: indexPath)
            guard let addItemCell = item as? AddItemCell else { return item }
            addItemCell.delegate = self
            return addItemCell
        }

        let item = collectionView.makeItem(withIdentifier: taskItemIdentifier, for: indexPath)
        guard let collectionViewItem = item as? TaskCell else { return item }
        collectionViewItem.configure(with: items[indexPath.item].toTaskModel(), index: indexPath.item)
        collectionViewItem.delegate = self
        return collectionViewItem
    }

    private func loadItems(isInitial: Bool) {
        Task {
            do {
                let loaded = try await repository.load()
                await MainActor.run {
                    self.items = loaded
                    self.collectionView.reloadData()
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
        let indexOfKGS = items.firstIndex { $0.title == "KGS" }
        openAt(indexOfKGS)
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

// Collection view click delegate
extension HomeController: OpenUrlProtocol {
    func openAt(_ index: Int?) {
        if let index {
            let item = items[index]
            let appDelegate = NSApplication.shared.delegate as? AppDelegate
            guard let windowFactory = appDelegate?.windowFactory else { return }
            let browser = windowFactory.create(windowType: .browser(item.url))
            browser.showWindoww(self)
        }
    }
}

extension HomeController: AddItemProtocol {
    func didTapAddItem() {
        presentAddItemPrompt()
    }
}
