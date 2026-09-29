//
//  MenuPane.swift
//  myBrowser_UIKit
//

import AppKit

/// A hamburger-menu section's content pane — see `MenuContentController.pane(for:)`.
@MainActor
protocol MenuPane: AnyObject {
    var view: NSView { get }
    func load(for item: HamburgerMenuItem) async
}
