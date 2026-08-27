//
//  ItemModelSection.swift
//  myBrowser_UIKit
//

import Foundation

/// The `HamburgerMenuItem` cases that are backed by a `FirebaseJSONRepository<[ItemModel]>`.
/// `.pdfLibrary` has no corresponding case — see `HamburgerMenuItem.itemModelSection`, which maps
/// a menu item to its section (or `nil`) and is the only place that needs updating when a new
/// `HamburgerMenuItem` case is added.
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
