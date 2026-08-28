//
//  BWWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

protocol RootWindowControllerProtocol: AnyObject {
    var identifier: String { get }
    func presentWindow(_ sender: Any?)
}

class RootWindowController: NSWindowController, RootWindowControllerProtocol {
    let identifier: String
    private var windowTracker: WindowLifecycleRecording

    init(window: NSWindow, identifier: String, windowTracker: WindowLifecycleRecording) {
        self.identifier = identifier
        self.windowTracker = windowTracker
        super.init(window: window)
        self.window?.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentWindow(_ sender: Any?) {
        showWindow(sender)
    }
}

extension RootWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let w = notification.object as? NSWindow else { return }
        guard let wd = w.windowController as? RootWindowControllerProtocol else { return }
        windowTracker.didClose(window: wd)
    }

    func windowDidBecomeKey(_ notification: Notification) {
        guard let w = notification.object as? NSWindow else { return }
        guard let wd = w.windowController as? RootWindowController else { return }
        windowTracker.setCurrent(window: wd)
    }

    func windowDidMiniaturize(_ notification: Notification) {
        guard let w = notification.object as? NSWindow else { return }
        guard let wd = w.windowController as? RootWindowController else { return }
        windowTracker.markMinimized(window: wd)
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        guard let w = notification.object as? NSWindow else { return }
        guard let wd = w.windowController as? RootWindowController else { return }
        windowTracker.resetMinimized(window: wd)
    }
}
