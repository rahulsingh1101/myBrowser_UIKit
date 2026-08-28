//
//  MainContainerController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 17/05/25.
//

import Cocoa
import SwiftUI
import WebKit

final class MainContainerController: NSViewController {
    let searchField = NSSearchField()
    let webViewController: MenuContentController
    let hamburgerButton = NSButton()
    private let windowCreating: WindowCreating

    init(windowCreating: WindowCreating) {
        self.windowCreating = windowCreating
        self.webViewController = MenuContentController(windowCreating: windowCreating)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var menuPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        let hostingController = NSHostingController(
            rootView: HamburgerMenuView(onSelect: { [weak self] item in
                self?.webViewController.select(item)
                self?.menuPopover.performClose(nil)
            })
        )
        hostingController.sizingOptions = [.preferredContentSize]
        popover.contentViewController = hostingController
        return popover
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

        // 1. Configure Hamburger Button
        hamburgerButton.translatesAutoresizingMaskIntoConstraints = false
        hamburgerButton.image = NSImage(systemSymbolName: "line.3.horizontal", accessibilityDescription: "Menu")
        hamburgerButton.isBordered = false
        hamburgerButton.bezelStyle = .regularSquare
        hamburgerButton.target = self
        hamburgerButton.action = #selector(toggleMenu)

        // 2. Configure Search Field
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholderString = "Enter URL"
        searchField.target = self
        searchField.action = #selector(loadURL)
        searchField.sendsSearchStringImmediately = false
        searchField.sendsWholeSearchString = true

        // 3. Top bar: hamburger button + search field
        let topBar = NSStackView()
        topBar.orientation = .horizontal
        topBar.distribution = .fill
        topBar.alignment = .centerY
        topBar.spacing = 10
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.addArrangedSubview(hamburgerButton)
        topBar.addArrangedSubview(searchField)

        // 4. Add subviews to stack view
        stackView.addArrangedSubview(topBar)
        stackView.addArrangedSubview(webViewController.view)

        // Add stack view to main view
        self.view.addSubview(stackView)

        // Layout Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),

            topBar.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            hamburgerButton.widthAnchor.constraint(equalToConstant: 30),
            hamburgerButton.heightAnchor.constraint(equalToConstant: 30),
            searchField.heightAnchor.constraint(equalToConstant: 30),
            searchField.widthAnchor.constraint(equalTo: topBar.widthAnchor, constant: -40),
            webViewController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }

    @objc private func toggleMenu() {
        if menuPopover.isShown {
            menuPopover.performClose(nil)
        } else {
            menuPopover.show(relativeTo: hamburgerButton.bounds, of: hamburgerButton, preferredEdge: .minY)
        }
    }

    @objc private func loadURL() {
        guard let url = searchField.stringValue.normalizedURL() else { return }
        let browser = windowCreating.create(windowType: .browser(url.absoluteString))
        browser.presentWindow(self)
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

extension NSObject {
    class var className: String {
        String(describing: self)
    }
}
