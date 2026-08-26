//
//  HamburgerMenuView.swift
//  myBrowser_UIKit
//

import SwiftUI

struct HamburgerMenuView: View {
    let onSelect: (HamburgerMenuItem) -> Void

    var body: some View {
        List(HamburgerMenuItem.allCases) { item in
            Text(item.title)
                .contentShape(Rectangle())
                .onTapGesture { onSelect(item) }
        }
        .frame(width: 200, height: CGFloat(HamburgerMenuItem.allCases.count) * 28 + 16)
    }
}
