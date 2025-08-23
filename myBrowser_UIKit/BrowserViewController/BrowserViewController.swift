//
//  UrlLoadingViewController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa
import WebKit

final class BrowserViewController: NSViewController {
    struct Model {
        let urlToLoad: String
        let title: String
    }

    let searchField = NSSearchField()
    private var popups: Set<RootWindowController> = []
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true // needed for window.open
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.uiDelegate = self
        wv.navigationDelegate = self
        wv.allowsBackForwardNavigationGestures = true
        return wv
    }()
    
    override func loadView() {
        // Main container view
        self.view = NSView()
        
        // Stack View
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        
        // 1. Configure Search Field
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholderString = "Enter URL"
        searchField.target = self
        searchField.action = #selector(loadURL)
        searchField.sendsSearchStringImmediately = false
        searchField.sendsWholeSearchString = true
        
        // 2. Add subviews to stack view
        stackView.addArrangedSubview(searchField)
        stackView.addArrangedSubview(webView)
        
        // Add stack view to main view
        self.view.addSubview(stackView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            
            searchField.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func preloadClass(data: Model) {
        searchField.stringValue = data.urlToLoad
    }
    
    @objc func loadURL() {
        print(">>>>>>>>>>>>>>>>  loadURL called :: >>>>>>>>>>>>>>>>>>>>>>>>>")
        let urlString = searchField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !urlString.isEmpty else {
            return
        }
        
        var finalURLString = urlString
        if !urlString.starts(with: "http://") && !urlString.starts(with: "https://") {
            finalURLString = "https://\(urlString)"
        }
        
        if let url = URL(string: finalURLString) {
            print("Started loading...::\(url)")
            webView.load(URLRequest(url: url))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension BrowserViewController: WKNavigationDelegate {
    // Called when loading starts
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Started loading...")
    }

    // Called when loading finishes successfully
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished loading. ::\(webView.url)")
        self.searchField.stringValue = webView.url?.absoluteString ?? ""
        self.view.window?.title = webView.title ?? (webView.url?.host ?? "Browser")
    }

    // Called when loading fails
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load: \(error.localizedDescription)")
    }

    // Called when initial load fails (before any content is shown)
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Failed to start loading: \(error.localizedDescription)")
    }
}

extension BrowserViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let appDelegate = NSApplication.shared.delegate as? AppDelegate
        guard let windowFactory = appDelegate?.windowFactory else { return nil }
        guard let popup = windowFactory.create(windowType: .popup(configuration)) as? PopupWindowController else { return nil }
        // Optional: apply requested size/position from windowFeatures
        if let w = windowFeatures.width?.doubleValue, let h = windowFeatures.height?.doubleValue {
            popup.window?.setContentSize(NSSize(width: w, height: h))
        }
        if let x = windowFeatures.x?.doubleValue, let y = windowFeatures.y?.doubleValue {
            popup.window?.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        popups.insert(popup) // retain
        popup.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        
        // Return the actual WKWebView that’s embedded in the new window
        return popup.webView
    }
}
