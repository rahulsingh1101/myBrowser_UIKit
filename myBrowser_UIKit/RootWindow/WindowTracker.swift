//
//  WindowTracker.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 24/08/25.
//

import AppKit

protocol WindowTrackerProtocol {
    func add(window: RootWindowControllerProtocol)
    func getCreatedWindow(for identifier: String) -> RootWindowControllerProtocol?
    func didClose(window: RootWindowControllerProtocol)
    func resetMinimized(window: RootWindowControllerProtocol)
    func getWindowForDockClick() -> RootWindowControllerProtocol?
    var minimizedWindow: [RootWindowControllerProtocol] {get set}
    var currentWindow: RootWindowControllerProtocol? { get set}
}

final class WindowTracker: WindowTrackerProtocol {
    private var createdWindows = [RootWindowControllerProtocol]()
    var minimizedWindow: [RootWindowControllerProtocol] = []
    var currentWindow: RootWindowControllerProtocol?
    
    func add(window: RootWindowControllerProtocol) {
        createdWindows.append(window)
    }
    
    func didClose(window: RootWindowControllerProtocol) {
        let id = NSUserInterfaceItemIdentifier(window.identifier)
        if currentWindow?.identifier == id.rawValue {
            currentWindow = nil
        }
        createdWindows.removeAll {
            $0.identifier == id.rawValue
        }
    }

    func resetMinimized(window: RootWindowControllerProtocol) {
        minimizedWindow.removeAll { $0.identifier == window.identifier }
    }

    func getWindowForDockClick() -> RootWindowControllerProtocol? {
//        click on dock if any present window -> ignore
//        click on dock if current nil, minimized != nil -> restore minimized window
//        click on dock if current nil, minimized nil -> create main window

        if let currentWindow = currentWindow {
            return currentWindow
        }
        if currentWindow == nil, let minimizedWindow = minimizedWindow.last {
            return minimizedWindow
        }
        return nil
    }

    func getCreatedWindow(for identifier: String) -> RootWindowControllerProtocol? {
        return createdWindows.first { $0.identifier == identifier }
    }
}
