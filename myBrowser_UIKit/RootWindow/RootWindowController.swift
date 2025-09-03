//
//  BWWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

protocol RootWindowControllerProtocol: AnyObject {
    var identifier: String { get }
    func showWindoww(_ sender: Any?)
    func reloadURL()
}

class RootWindowController: NSWindowController, RootWindowControllerProtocol {
    let identifier: String
    private var windowTracker: WindowTrackerProtocol
    
    init(window: NSWindow, identifier: String, windowTracker: WindowTrackerProtocol) {
        self.identifier = identifier
        self.windowTracker = windowTracker
        super.init(window: window)
        self.window?.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWindoww(_ sender: Any?) {
        showWindow(sender)
    }
    
    func reloadURL() {
        fatalError("Subclasses must override \(#function)")
    }
}

extension RootWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let w = notification.object as? NSWindow else { return }
        print("CLOSE → \(w.title)")
        guard let wd = w.windowController as? RootWindowControllerProtocol else { return }
        print("CLOSE identifier → \(wd.identifier)")
        windowTracker.didClose(window: wd)
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        guard let w = notification.object as? NSWindow else { return }
        print("KEY → \(w.title) (#\(w.windowNumber))")
        
        guard let wd = w.windowController as? RootWindowController else { return }
        windowTracker.currentWindow = wd
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        guard let w = notification.object as? NSWindow else { return }
        print("MAIN → \(w.title) (#\(w.windowNumber))")
        // “Open” is typically the first time a window becomes main/key (after makeKeyAndOrderFront).
    }

    func windowWillMiniaturize(_ notification: Notification) {
        print("WILL MINIMIZE notification object :: \(notification)")
        guard let w = notification.object as? NSWindow else { return }
        print("WILL MINIMIZE → \(w.title) (#\(w.windowNumber))")
        
        guard let wd = w.windowController as? RootWindowController else { return }
        print("WILL MINIMIZE identifier → \(wd.identifier)")
        windowTracker.minimizedWindow.append(wd)
    }

    func windowDidMiniaturize(_ notification: Notification) {
        print("DID MINIMIZE notification object :: \(notification)")
        guard let w = notification.object as? NSWindow else { return }
        print("DID MINIMIZE → \(w.title) (#\(w.windowNumber))")
        
        guard let wd = w.windowController as? RootWindowController else { return }
        print("DID MINIMIZE identifier → \(wd.identifier)")
        windowTracker.minimizedWindow.append(wd)
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        guard let w = notification.object as? NSWindow else { return }
        print("RESTORED FROM MINIMIZE → \(w.title) (#\(w.windowNumber))")
        guard let wd = w.windowController as? RootWindowController else { return }
        windowTracker.resetMinimized(window: wd)
    }
}
