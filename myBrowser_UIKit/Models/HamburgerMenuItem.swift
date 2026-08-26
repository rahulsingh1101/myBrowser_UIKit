//
//  HamburgerMenuItem.swift
//  myBrowser_UIKit
//

import Foundation

enum HamburgerMenuItem: String, CaseIterable, Identifiable, Equatable {
    case home
    case focusMusic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .focusMusic: return "Focus Music"
        }
    }

    var repository: FirebaseJSONRepository<[ItemModel]> {
        switch self {
        case .home: return .preloadWebsites()
        case .focusMusic: return .focusMusic()
        }
    }
}
