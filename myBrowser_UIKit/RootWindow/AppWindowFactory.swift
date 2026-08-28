//
//  AppWindowFactory.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 24/08/25.
//

import AppKit
import WebKit

protocol WindowRequest {
    /// `nil` means never de-duped (currently only `PopupWindowRequest`).
    var dedupeIdentifier: String? { get }
    func makeController(tracker: WindowTrackerProtocol, windowCreating: WindowCreating) -> RootWindowControllerProtocol
}

struct MainWindowRequest: WindowRequest {
    var dedupeIdentifier: String? { "main" }

    func makeController(tracker: WindowTrackerProtocol, windowCreating: WindowCreating) -> RootWindowControllerProtocol {
        MainContainerWindowController(identifier: NSUserInterfaceItemIdentifier("main").rawValue, windowTracker: tracker, windowCreating: windowCreating)
    }
}

struct BrowserWindowRequest: WindowRequest {
    let urlString: String
    var dedupeIdentifier: String? { urlString }

    func makeController(tracker: WindowTrackerProtocol, windowCreating: WindowCreating) -> RootWindowControllerProtocol {
        BrowserWindowController(identifier: NSUserInterfaceItemIdentifier(urlString).rawValue, model: .init(urlToLoad: urlString, title: urlString), windowTracker: tracker, windowCreating: windowCreating)
    }
}

struct PopupWindowRequest: WindowRequest {
    let configuration: WKWebViewConfiguration
    var dedupeIdentifier: String? { nil }

    func makeController(tracker: WindowTrackerProtocol, windowCreating: WindowCreating) -> RootWindowControllerProtocol {
        PopupWindowController(identifier: UUID().uuidString, configuration: configuration, windowTracker: tracker)
    }
}

struct BrowserPopupWindowRequest: WindowRequest {
    let configuration: WKWebViewConfiguration
    let urlString: String
    var dedupeIdentifier: String? { urlString }

    func makeController(tracker: WindowTrackerProtocol, windowCreating: WindowCreating) -> RootWindowControllerProtocol {
        BrowserWindowController(identifier: NSUserInterfaceItemIdentifier(urlString).rawValue, configuration: configuration, windowTracker: tracker, windowCreating: windowCreating)
    }
}

struct ReaderWindowRequest: WindowRequest {
    let item: PDFLibraryItem
    var dedupeIdentifier: String? { item.id }

    func makeController(tracker: WindowTrackerProtocol, windowCreating: WindowCreating) -> RootWindowControllerProtocol {
        ReaderWindowController(identifier: item.id, item: item, windowTracker: tracker)
    }
}

protocol WindowCreating {
    func create(_ request: WindowRequest) -> RootWindowControllerProtocol
}

final class AppWindowFactory: WindowCreating {
    let windowTracker: WindowTrackerProtocol = WindowTracker()

    func create(_ request: WindowRequest) -> RootWindowControllerProtocol {
        if let windowController = checkIfAlreadyPresent(request: request) {
            return windowController
        }
        let windowController = request.makeController(tracker: windowTracker, windowCreating: self)
        if request.dedupeIdentifier != nil {
            windowTracker.add(window: windowController)
        }
        return windowController
    }

    private func checkIfAlreadyPresent(request: WindowRequest) -> RootWindowControllerProtocol? {
        guard let id = request.dedupeIdentifier else { return nil }
        return windowTracker.getCreatedWindow(for: id)
    }
}
