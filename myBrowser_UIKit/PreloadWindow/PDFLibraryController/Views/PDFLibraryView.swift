//
//  PDFLibraryView.swift
//  myBrowser_UIKit
//

import SwiftUI

struct PDFLibraryView: View {
    @ObservedObject var viewModel: GenericLibraryViewModel<PDFLibraryItem>
    let onOpen: (PDFLibraryItem) -> Void
    let onAdd: () -> Void
    let onDelete: (PDFLibraryItem) -> Void

    private let columns = [GridItem(.adaptive(minimum: 300, maximum: 300), spacing: 10)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.items) { item in
                    PDFCardView(
                        item: item,
                        onOpen: { onOpen(item) },
                        onDelete: { onDelete(item) }
                    )
                }
                AddTaskCardView(onAdd: onAdd)
            }
            .padding(10)
        }
    }
}
