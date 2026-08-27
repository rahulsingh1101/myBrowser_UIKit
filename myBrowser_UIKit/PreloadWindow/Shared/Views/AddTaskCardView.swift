//
//  AddTaskCardView.swift
//  myBrowser_UIKit
//

import SwiftUI

struct AddTaskCardView: View {
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            Text("+")
                .font(.system(size: 24, weight: .medium))
        }
        .buttonStyle(.plain)
        .frame(width: 300, height: 100)
        .background(Color(nsColor: .lightGray).opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .lightGray).opacity(0.4), lineWidth: 1)
        )
    }
}
