//
//  HamburgerMenuItem.swift
//  myBrowser_UIKit
//

import Foundation

enum HamburgerMenuItem: String, CaseIterable, Identifiable, Hashable {
    case home
    case focusMusic
    case pdfLibrary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .focusMusic: return "Focus Music"
        case .pdfLibrary: return "My PDFs"
        }
    }

    private static let itemModelRepositories: [HamburgerMenuItem: FirebaseJSONRepository<[ItemModel]>] = [
        .home: .preloadWebsites(),
        .focusMusic: .focusMusic()
    ]

    /// `nil` for sections not backed by a `FirebaseJSONRepository<[ItemModel]>` (currently `.pdfLibrary`, which uses its own `GenericLibraryViewModel<PDFLibraryItem>` pipeline instead — see `MenuContentController`).
    var itemModelRepository: FirebaseJSONRepository<[ItemModel]>? {
        Self.itemModelRepositories[self]
    }
}
