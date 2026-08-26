//
//  PDFBookmark.swift
//  myBrowser_UIKit
//

import Foundation

enum PDFBookmark {
    /// A security-scoped bookmark is what's needed for access to survive a relaunch, but creating one
    /// requires the app's provisioning profile to have App Sandbox properly registered with Apple — a
    /// plain local "Development" signature without one can fail here even though the sandbox otherwise
    /// grants read access. Falling back to a plain bookmark keeps local/unsigned-profile builds working.
    static func makeData(for url: URL) throws -> Data {
        if let data = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
            return data
        }
        return try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
    }

    static func resolve(_ data: Data) -> URL? {
        var isStale = false
        if let url = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) {
            return url
        }
        return try? URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
    }
}
