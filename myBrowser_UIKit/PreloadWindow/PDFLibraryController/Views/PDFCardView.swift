//
//  PDFCardView.swift
//  myBrowser_UIKit
//

import SwiftUI

struct PDFCardView: View {
    let item: PDFLibraryItem
    let onOpen: () -> Void
    let onDelete: () -> Void

    private var subtitle: String {
        item.lastReadPage > 0 ? "Last read: page \(item.lastReadPage + 1)" : "Not started"
    }

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
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(6)
        }
    }
}
