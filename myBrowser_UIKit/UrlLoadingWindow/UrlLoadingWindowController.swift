//
//  UrlLoadingWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

final class UrlLoadingWindowController: BWWindowController, NSWindowDelegate {
    init(identifier: String, model: UrlLoadingViewController.Model) {
        let viewController = UrlLoadingViewController()
        viewController.preloadClass(data: model)
        let window = NSWindow(contentViewController: viewController)
        let visibleFrame = NSScreen.main!.visibleFrame
        window.setContentSize(visibleFrame.size)
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.title = "My Custom Window"
        super.init(window: window, identifier: identifier)
        self.window?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    func windowWillClose(_ notification: Notification) {
        delegate?.windowWillClose(self)
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        delegate?.windowDidBecomekey(self)
    }
}
