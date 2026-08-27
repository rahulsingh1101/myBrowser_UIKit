//
//  ReaderWindowController.swift
//  myBrowser_UIKit
//

import Cocoa

final class ReaderWindowController: RootWindowController {
    init(identifier: String, item: PDFLibraryItem, windowTracker: WindowTrackerProtocol) {
        let viewController = PDFReaderViewController()
        viewController.load(item: item)
        let window = NSWindow(contentViewController: viewController)
        let visibleFrame = NSScreen.mainVisibleFrameOrDefault
        window.setContentSize(visibleFrame.size)
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.title = item.title
        super.init(window: window, identifier: identifier, windowTracker: windowTracker)
        self.window?.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
