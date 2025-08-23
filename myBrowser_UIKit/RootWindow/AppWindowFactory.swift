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
}

final class AppWindowFactory {
    let windowTracker = WindowTracker()
    
    func create(windowType: WindowType) -> RootWindowControllerProtocol {
        if let windowController = checkIfAlreadyPresent(windowType: windowType) {
            return windowController
        }
        switch windowType {
        case .main:
            let windowController = MainWindowController(identifier: NSUserInterfaceItemIdentifier("main").rawValue, title: "Search / Bookmark - 1", windowTracker: windowTracker)
            windowTracker.add(window: windowController)
            return windowController
        case .browser(let urlString):
            let windowController = BrowserWindowController(identifier: NSUserInterfaceItemIdentifier(urlString).rawValue, model: .init(urlToLoad: urlString, title: urlString), windowTracker: windowTracker)
            windowTracker.add(window: windowController)
            return windowController
        case .popup(let configuration):
            let windowController = PopupWindowController(configuration: configuration, windowTracker: windowTracker)
            return windowController
        }
    }
    
    private func checkIfAlreadyPresent(windowType: WindowType) -> RootWindowControllerProtocol? {
        switch windowType {
        case .main:
            return windowTracker.getCreatedWindow(for: "main")
        case .browser(let string):
            return windowTracker.getCreatedWindow(for: string)
        case .popup:
            break
        }
        return nil
    }
}
