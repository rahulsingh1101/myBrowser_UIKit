//
//  ItemModelSection.swift
//  myBrowser_UIKit
//

import Foundation

/// The `HamburgerMenuItem` cases that are backed by a `FirebaseJSONRepository<[ItemModel]>`.
/// `.pdfLibrary` has no corresponding case, so there is no repository to fetch for it by mistake.
enum ItemModelSection: CaseIterable {
    case home
    case focusMusic

    init?(menuItem: HamburgerMenuItem) {
        switch menuItem {
        case .home: self = .home
        case .focusMusic: self = .focusMusic
        case .pdfLibrary: return nil
        }
    }

    var repository: FirebaseJSONRepository<[ItemModel]> {
        switch self {
        case .home: return .preloadWebsites()
        case .focusMusic: return .focusMusic()
        }
    }
}
