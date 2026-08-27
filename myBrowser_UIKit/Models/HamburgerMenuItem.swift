//
//  HamburgerMenuItem.swift
//  myBrowser_UIKit
//

import Foundation

enum HamburgerMenuItem: String, CaseIterable, Identifiable, Equatable {
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
}
