//
//  GridMenuPane.swift
//  myBrowser_UIKit
//

import AppKit
import SwiftUI

/// Shares one grid view + view model across every `HamburgerMenuItem` key in `repositories`.
@MainActor
final class GridMenuPane<Item: Codable & Identifiable & LibraryDisplayable>: MenuPane {
    let viewModel: GenericLibraryViewModel<Item>
    private let repositories: [HamburgerMenuItem: FirebaseJSONRepository<[Item]>]
    private let hostController: SwiftUIHostController<LibraryGridView<Item>>
    private let makeView: () -> LibraryGridView<Item>

    var view: NSView { hostController.view }

    init(
        viewModel: GenericLibraryViewModel<Item>,
        repositories: [HamburgerMenuItem: FirebaseJSONRepository<[Item]>],
        subtitle: @escaping (Item) -> String,
        onOpen: @escaping (Item) -> Void,
        onAdd: @escaping () -> Void,
        onDelete: ((Item) -> Void)? = nil,
        onCopyURL: ((Item) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.repositories = repositories
        let makeView = {
            LibraryGridView(
                viewModel: viewModel,
                subtitle: subtitle,
                onOpen: onOpen,
                onAdd: onAdd,
                onDelete: onDelete,
                onCopyURL: onCopyURL
            )
        }
        self.makeView = makeView
        self.hostController = SwiftUIHostController(rootView: makeView())
    }

    func repository(for item: HamburgerMenuItem) -> FirebaseJSONRepository<[Item]>? {
        repositories[item]
    }

    func load(for item: HamburgerMenuItem) async {
        hostController.updateRootView(makeView())
        guard let repository = repositories[item] else { return }
        await viewModel.load(from: repository)
    }
}
