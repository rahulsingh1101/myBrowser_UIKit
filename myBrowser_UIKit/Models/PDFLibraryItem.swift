//
//  PDFLibraryItem.swift
//  myBrowser_UIKit
//

import Foundation

struct PDFLibraryItem: Codable, Identifiable {
    let id: String
    var title: String
    var bookmarkData: Data
    var lastReadPage: Int
    var dateAdded: TimeInterval
}

extension PDFLibraryItem: LibraryDisplayable {}
