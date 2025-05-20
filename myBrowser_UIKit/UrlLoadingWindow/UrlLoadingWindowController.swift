//
//  UrlLoadingWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

final class UrlLoadingWindowController: BWWindowController {
    init(identifier: String, model: UrlLoadingViewController.Model) {
        let viewController = UrlLoadingViewController()
        viewController.preloadClass(data: model)
        let window = NSWindow(contentViewController: viewController)
        let visibleFrame = NSScreen.main!.visibleFrame
        window.setContentSize(visibleFrame.size)
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.title = model.title
        super.init(window: window, identifier: identifier)
        self.window?.delegate = self
        viewController.loadURL()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func reloadURL() {
        let viewController = self.window?.contentViewController as? UrlLoadingViewController
        viewController?.loadURL()
    }
}
