//
//  String+URLNormalization.swift
//  myBrowser_UIKit
//

import Foundation

extension String {
    func normalizedURL() -> URL? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let withScheme = (trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://"))
            ? trimmed
            : "https://\(trimmed)"

        return URL(string: withScheme)
    }
}
