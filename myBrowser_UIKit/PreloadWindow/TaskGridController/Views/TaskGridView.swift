//
//  TaskGridView.swift
//  myBrowser_UIKit
//

import SwiftUI

struct TaskGridView: View {
    @ObservedObject var viewModel: TaskGridViewModel
    let onOpen: (ItemModel) -> Void
    let onAdd: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 300, maximum: 300), spacing: 10)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.items) { item in
                    TaskCardView(item: item, onOpen: { onOpen(item) })
                }
                AddTaskCardView(onAdd: onAdd)
            }
            .padding(10)
        }
    }
}
