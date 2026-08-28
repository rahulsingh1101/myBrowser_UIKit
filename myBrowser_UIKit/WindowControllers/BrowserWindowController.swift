//
//  UrlLoadingWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa
import WebKit

final class BrowserWindowController: RootWindowController {
    init(identifier: String, model: BrowserViewController.Model, windowTracker: WindowLifecycleRecording) {
        let viewController = BrowserViewController()
        viewController.preloadClass(data: model)
        let window = NSWindow(contentViewController: viewController)
        let visibleFrame = NSScreen.mainVisibleFrameOrDefault
        window.setContentSize(visibleFrame.size)
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.title = model.title
        super.init(window: window, identifier: identifier, windowTracker: windowTracker)
        self.window?.delegate = self
    }

    init(identifier: String, configuration: WKWebViewConfiguration, windowTracker: WindowLifecycleRecording) {
        let viewController = BrowserViewController(configuration: configuration)
        let window = NSWindow(contentViewController: viewController)
        let visibleFrame = NSScreen.mainVisibleFrameOrDefault
        let size = NSSize(width: visibleFrame.width * 0.75, height: visibleFrame.height * 0.75)
        let origin = NSPoint(
            x: visibleFrame.minX + (visibleFrame.width - size.width) / 2,
            y: visibleFrame.minY + (visibleFrame.height - size.height) / 2
        )
        window.setFrame(NSRect(origin: origin, size: size), display: false)
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        super.init(window: window, identifier: identifier, windowTracker: windowTracker)
        self.window?.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var webView: WKWebView? {
        (contentViewController as? BrowserViewController)?.webView
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
