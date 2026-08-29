//
//  LibraryGridView.swift
//  myBrowser_UIKit
//

import SwiftUI

struct LibraryGridView<Item: Codable & Identifiable & LibraryDisplayable>: View {
    @ObservedObject var viewModel: GenericLibraryViewModel<Item>
    let subtitle: (Item) -> String
    let onOpen: (Item) -> Void
    let onAdd: () -> Void
    var onDelete: ((Item) -> Void)? = nil
    var onCopyURL: ((Item) -> Void)? = nil

    private let columns = [GridItem(.adaptive(minimum: 300, maximum: 300), spacing: 10)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.items) { item in
                    LibraryCardView(
                        item: item,
                        subtitle: subtitle(item),
                        onOpen: { onOpen(item) },
                        onDelete: onDelete.map { delete in { delete(item) } },
                        onCopyURL: onCopyURL.map { copy in { copy(item) } }
                    )
                }
                AddTaskCardView(onAdd: onAdd)
            }
            .padding(10)
        }
    }
}
