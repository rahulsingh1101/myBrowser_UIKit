//
//  DefaultWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

final class MainContainerWindowController: RootWindowController {
    init(identifier: String, windowTracker: WindowLifecycleRecording, windowCreating: WindowCreating) {
        let viewController = MainContainerController(windowCreating: windowCreating)
        let window = NSWindow(contentViewController: viewController)
        let visibleFrame = NSScreen.mainVisibleFrameOrDefault
        window.setContentSize(visibleFrame.size)
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.title = "Search / Bookmark - 1"
        super.init(window: window, identifier: identifier, windowTracker: windowTracker)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
