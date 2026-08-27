//
//  NSScreen+VisibleFrame.swift
//  myBrowser_UIKit
//

import AppKit

extension NSScreen {
    /// Falls back to a fixed frame instead of crashing when no screen is available.
    static var mainVisibleFrameOrDefault: NSRect {
        NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
    }
}
