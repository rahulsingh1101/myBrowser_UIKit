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
    private let backButton = NSButton()
    private let forwardButton = NSButton()
    private var popups: Set<RootWindowController> = []
    private var urlObservation: NSKeyValueObservation?
    private var canGoBackObservation: NSKeyValueObservation?
    private var canGoForwardObservation: NSKeyValueObservation?

    private let externalConfiguration: WKWebViewConfiguration?
    private let windowCreating: WindowCreating

    init(configuration: WKWebViewConfiguration? = nil, windowCreating: WindowCreating) {
        self.externalConfiguration = configuration
        self.windowCreating = windowCreating
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var webView: WKWebView = {
        let config = externalConfiguration ?? {
            let config = WKWebViewConfiguration()
            config.preferences.javaScriptEnabled = true
            config.preferences.javaScriptCanOpenWindowsAutomatically = true // needed for window.open
            config.defaultWebpagePreferences.allowsContentJavaScript = true
            return config
        }()

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.uiDelegate = self
        wv.navigationDelegate = self
        wv.allowsBackForwardNavigationGestures = true

        // WKNavigationDelegate callbacks don't fire for same-document navigations
        // (SPA pushState/replaceState, e.g. Coursera's module switcher), so the
        // search field must be kept in sync via KVO on `url` instead.
        urlObservation = wv.observe(\.url, options: [.new]) { [weak self] webView, _ in
            guard let self, let url = webView.url else { return }
            DispatchQueue.main.async {
                self.searchField.stringValue = url.absoluteString
            }
        }

        canGoBackObservation = wv.observe(\.canGoBack, options: [.initial, .new]) { [weak self] webView, _ in
            DispatchQueue.main.async {
                self?.backButton.isEnabled = webView.canGoBack
            }
        }

        canGoForwardObservation = wv.observe(\.canGoForward, options: [.initial, .new]) { [weak self] webView, _ in
            DispatchQueue.main.async {
                self?.forwardButton.isEnabled = webView.canGoForward
            }
        }

        return wv
    }()

    deinit {
        urlObservation?.invalidate()
        canGoBackObservation?.invalidate()
        canGoForwardObservation?.invalidate()
    }

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
        
        // 1. Configure back/forward buttons
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.bezelStyle = .texturedRounded
        backButton.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: "Back")
        backButton.target = self
        backButton.action = #selector(goBack)
        backButton.keyEquivalent = "["
        backButton.keyEquivalentModifierMask = .command
        backButton.isEnabled = false

        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.bezelStyle = .texturedRounded
        forwardButton.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: "Forward")
        forwardButton.target = self
        forwardButton.action = #selector(goForward)
        forwardButton.keyEquivalent = "]"
        forwardButton.keyEquivalentModifierMask = .command
        forwardButton.isEnabled = false

        // 2. Configure Search Field
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholderString = "Enter URL"
        searchField.target = self
        searchField.action = #selector(loadURL)
        searchField.sendsSearchStringImmediately = false
        searchField.sendsWholeSearchString = true

        // 3. Navigation bar: back/forward + search field, inline
        let navBar = NSStackView(views: [backButton, forwardButton, searchField])
        navBar.orientation = .horizontal
        navBar.distribution = .fill
        navBar.alignment = .centerY
        navBar.spacing = 6
        navBar.translatesAutoresizingMaskIntoConstraints = false

        // 4. Add subviews to stack view
        stackView.addArrangedSubview(navBar)
        stackView.addArrangedSubview(webView)

        // Add stack view to main view
        self.view.addSubview(stackView)

        // Layout Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),

            navBar.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 30),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            forwardButton.widthAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadURL()
    }
    
    func preloadClass(data: Model) {
        searchField.stringValue = data.urlToLoad
    }
    
    @objc private func goBack() {
        webView.goBack()
    }

    @objc private func goForward() {
        webView.goForward()
    }

    @objc private func loadURL() {
        guard let url = searchField.stringValue.normalizedURL() else { return }
        webView.load(URLRequest(url: url))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.window?.title = webView.title ?? (webView.url?.host ?? "Browser")
    }
}

extension BrowserViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let urlString = navigationAction.request.url?.absoluteString ?? UUID().uuidString
        guard let popup = windowCreating.create(BrowserPopupWindowRequest(configuration: configuration, urlString: urlString)) as? BrowserWindowController,
              let popupWebView = popup.webView else { return nil }

        popups.insert(popup) // retain
        popup.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)

        // Return the actual WKWebView that’s embedded in the new window
        return popupWebView
    }
}
