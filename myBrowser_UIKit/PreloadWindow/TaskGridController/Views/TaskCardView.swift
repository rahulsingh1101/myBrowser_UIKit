//
//  TaskCardView.swift
//  myBrowser_UIKit
//

import SwiftUI

struct TaskCardView: View {
    let item: ItemModel
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title)
                .font(.system(size: 14, weight: .bold))
            Text(item.subtitle)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            Button("Open", action: onOpen)
                .padding(.top, 8)
        }
        .padding(10)
        .frame(width: 300, height: 100, alignment: .topLeading)
        .background(Color(nsColor: .lightGray).opacity(0.2))
        .cornerRadius(8)
    }
}
