//
//  WebViewController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 17/05/25.
//

import Cocoa
import WebKit
import CoreDataManager

final class WebViewController: NSViewController {
    let webView = WKWebView()
    weak var delegate: UpdateSearchBarDelegate?

    override func loadView() {
        webView.navigationDelegate = self
        self.view = webView
    }

    func load(url: URL) {
        print("debug :: load url :: \(url)")
        webView.load(URLRequest(url: url))
    }
}

extension WebViewController: WKNavigationDelegate {
    // Called when loading starts
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("debug :: Started loading...")
    }

    // Called when loading finishes successfully
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("debug :: Finished loading. ::\(webView.url)")
        let searchItem = SearchResult(searchUrl: webView.url?.absoluteString ?? "")
        delegate?.updateSearchBar(with: webView.url?.absoluteString ?? "")
    }

    // Called when loading fails
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("debug :: Failed to load: \(error.localizedDescription)")
    }

    // Called when initial load fails (before any content is shown)
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("debug :: Failed to start loading: \(error.localizedDescription)")
    }
}

struct SearchResult: Codable {
    let searchUrl: String
}
