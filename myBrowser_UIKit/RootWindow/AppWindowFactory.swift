//
//  AppWindowFactory.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 24/08/25.
//

import AppKit
import WebKit

enum WindowType {
    case main
    case browser(String)
    case popup(WKWebViewConfiguration)
    case reader(PDFLibraryItem)
}

extension WindowType {
    /// `nil` means never de-duped (currently only `.popup`).
    var dedupeIdentifier: String? {
        switch self {
        case .main: return "main"
        case .browser(let urlString): return urlString
        case .popup: return nil
        case .reader(let item): return item.id
        }
    }
}

final class AppWindowFactory {
    let windowTracker: WindowTrackerProtocol = WindowTracker()

    func create(windowType: WindowType) -> RootWindowControllerProtocol {
        if let windowController = checkIfAlreadyPresent(windowType: windowType) {
            return windowController
        }
        switch windowType {
        case .main:
            let windowController = MainContainerWindowController(identifier: NSUserInterfaceItemIdentifier("main").rawValue, windowTracker: windowTracker)
            windowTracker.add(window: windowController)
            return windowController
        case .browser(let urlString):
            let windowController = BrowserWindowController(identifier: NSUserInterfaceItemIdentifier(urlString).rawValue, model: .init(urlToLoad: urlString, title: urlString), windowTracker: windowTracker)
            windowTracker.add(window: windowController)
            return windowController
        case .popup(let configuration):
            let windowController = PopupWindowController(identifier: UUID().uuidString, configuration: configuration, windowTracker: windowTracker)
            return windowController
        case .reader(let item):
            let windowController = ReaderWindowController(identifier: item.id, item: item, windowTracker: windowTracker)
            windowTracker.add(window: windowController)
            return windowController
        }
    }

    private func checkIfAlreadyPresent(windowType: WindowType) -> RootWindowControllerProtocol? {
        guard let id = windowType.dedupeIdentifier else { return nil }
        return windowTracker.getCreatedWindow(for: id)
    }
}
