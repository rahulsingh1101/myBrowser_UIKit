//
//  WindowTracker.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 24/08/25.
//

import AppKit

protocol WindowRegistering {
    func add(window: RootWindowControllerProtocol)
    func getCreatedWindow(for identifier: String) -> RootWindowControllerProtocol?
}

protocol WindowLifecycleRecording {
    func didClose(window: RootWindowControllerProtocol)
    func markMinimized(window: RootWindowControllerProtocol)
    func resetMinimized(window: RootWindowControllerProtocol)
    func setCurrent(window: RootWindowControllerProtocol?)
}

protocol DockClickResolving {
    func getWindowForDockClick() -> RootWindowControllerProtocol?
    var minimizedWindow: [RootWindowControllerProtocol] { get }
    var currentWindow: RootWindowControllerProtocol? { get }
}

/// New consumers should depend on the narrowest protocol above that covers what they call;
/// this composition exists for `AppWindowFactory`/`AppDelegate`, which legitimately need all three.
typealias WindowTrackerProtocol = WindowRegistering & WindowLifecycleRecording & DockClickResolving

final class WindowTracker: WindowTrackerProtocol {
    private var createdWindows = [RootWindowControllerProtocol]()
    private(set) var minimizedWindow: [RootWindowControllerProtocol] = []
    private(set) var currentWindow: RootWindowControllerProtocol?

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

    func markMinimized(window: RootWindowControllerProtocol) {
        minimizedWindow.append(window)
    }

    func resetMinimized(window: RootWindowControllerProtocol) {
        minimizedWindow.removeAll { $0.identifier == window.identifier }
    }

    func setCurrent(window: RootWindowControllerProtocol?) {
        currentWindow = window
    }

    func getWindowForDockClick() -> RootWindowControllerProtocol? {
        if let currentWindow = currentWindow {
            return currentWindow
        }
        if let minimizedWindow = minimizedWindow.last {
            return minimizedWindow
        }
        return nil
    }

    func getCreatedWindow(for identifier: String) -> RootWindowControllerProtocol? {
        return createdWindows.first { $0.identifier == identifier }
    }
}
