//
//  PDFLibraryMenuPane.swift
//  myBrowser_UIKit
//

import AppKit
import SwiftUI

@MainActor
final class PDFLibraryMenuPane: MenuPane {
    let viewModel: GenericLibraryViewModel<PDFLibraryItem>
    private let hostController: SwiftUIHostController<LibraryGridView<PDFLibraryItem>>

    var view: NSView { hostController.view }

    init(
        viewModel: GenericLibraryViewModel<PDFLibraryItem>,
        onOpen: @escaping (PDFLibraryItem) -> Void,
        onAdd: @escaping () -> Void,
        onDelete: @escaping (PDFLibraryItem) -> Void
    ) {
        self.viewModel = viewModel
        let gridView = LibraryGridView(
            viewModel: viewModel,
            subtitle: { $0.lastReadPage > 0 ? "Last read: page \($0.lastReadPage + 1)" : "Not started" },
            onOpen: onOpen,
            onAdd: onAdd,
            onDelete: onDelete
        )
        self.hostController = SwiftUIHostController(rootView: gridView)
    }

    func load(for item: HamburgerMenuItem) async {
        await viewModel.load(from: .pdfLibrary())
    }
}
