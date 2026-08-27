//
//  RepositoryBackedItemModel.swift
//  myBrowser_UIKit
//

import Foundation

/// The `HamburgerMenuItem` cases backed by a `FirebaseJSONRepository<[ItemModel]>` — see `HamburgerMenuItem.itemModelSection`.
enum RepositoryBackedItemModel: CaseIterable {
    case home
    case focusMusic

    var repository: FirebaseJSONRepository<[ItemModel]> {
        switch self {
        case .home: return .preloadWebsites()
        case .focusMusic: return .focusMusic()
        }
    }
}
