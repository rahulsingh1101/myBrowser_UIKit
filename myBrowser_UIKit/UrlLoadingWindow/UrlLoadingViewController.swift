//
//  UrlLoadingViewController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

final class UrlLoadingViewController: NSViewController {
    struct Model {
        let urlToLoad: String
        let title: String
    }

    let searchField = NSSearchField()
    let webViewController = WebViewController()
    
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
        stackView.addArrangedSubview(webViewController.view)
        
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
        webViewController.delegate = self
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
            print("debug :: Started loading...::\(url)")
            webViewController.load(url: url)
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

extension UrlLoadingViewController: WebViewDelegateProtocol {
    func webView(didFinish navigation: String) {
        self.searchField.stringValue = navigation
    }
}
