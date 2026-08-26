//
//  DefaultWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

final class MainContainerWindowController: RootWindowController {
    init(identifier: String, title: String, windowTracker: WindowTrackerProtocol) {
        let viewController = MainContainerController()
        let window = NSWindow(contentViewController: viewController)
        let visibleFrame = NSScreen.main!.visibleFrame
        window.setContentSize(visibleFrame.size)
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.title = title
        super.init(window: window, identifier: identifier, windowTracker: windowTracker)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
