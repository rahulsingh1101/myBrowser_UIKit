//
//  LibraryCardView.swift
//  myBrowser_UIKit
//

import SwiftUI

struct LibraryCardView<Item: Identifiable & LibraryDisplayable>: View {
    let item: Item
    let subtitle: String
    let onOpen: () -> Void
    var onDelete: (() -> Void)? = nil
    var onCopyURL: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil

    @State private var didCopy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(2)
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            HStack(spacing: 4) {
                Button("Open", action: onOpen)
                Spacer()
                if let onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Edit")
                }
                if let onCopyURL {
                    Button {
                        onCopyURL()
                        didCopy = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            didCopy = false
                        }
                    } label: {
                        Image(systemName: didCopy ? "checkmark.circle.fill" : "doc.on.doc")
                            .foregroundStyle(didCopy ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .help(didCopy ? "Copied!" : "Copy URL")
                }
                if let onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
        }
        .padding(10)
        .frame(minWidth: 300, maxWidth: 300, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .lightGray).opacity(0.2))
        .cornerRadius(8)
    }
}
