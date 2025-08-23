//
//  PopupWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 23/08/25.
//

import WebKit

final class PopupWindowController: RootWindowController, WKUIDelegate, WKNavigationDelegate {
    let webView: WKWebView

    init(configuration: WKWebViewConfiguration, windowTracker: WindowTracker) {
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        let vc = NSViewController()
        vc.view = NSView()
        vc.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
        ])

        let win = NSWindow(contentViewController: vc)
        win.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        win.setContentSize(NSSize(width: 900, height: 600))
        win.isReleasedWhenClosed = false

        super.init(window: win, identifier: "popup", windowTracker: windowTracker)
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // If page calls window.close(), WebKit will tell us so we can close the NSWindow:
    func webViewDidClose(_ webView: WKWebView) {
        self.close()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        window?.title = webView.title ?? (webView.url?.host ?? "Popup")
    }
}
