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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(1)
            Text(subtitle)
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
        .overlay(alignment: .topTrailing) {
            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(6)
            }
        }
    }
}
