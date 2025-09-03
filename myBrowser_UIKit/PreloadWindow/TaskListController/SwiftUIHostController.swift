//
//  SwiftUIHostController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 03/09/25.
//

import SwiftUI
import AppKit

// MARK: - Generic Approach (Recommended)
/// Generic controller that can host any SwiftUI view with proper lifecycle management
final class SwiftUIHostController<Content: View>: NSViewController {
    
    private var hostingController: NSHostingController<Content>
    private let swiftUIView: Content
    
    // MARK: - Initialization
    init(rootView: Content) {
        self.swiftUIView = rootView
        self.hostingController = NSHostingController(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHostingController()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        // Ensure proper layout on macOS
        hostingController.view.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupHostingController() {
        // Add as child controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Configure view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Use regular anchors instead of safeAreaLayoutGuide for macOS
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Complete the parent-child relationship - IMPORTANT!
        // Note: NSViewController doesn't have didMove(toParent:) like UIViewController
        // The relationship is established through addChild() and view hierarchy
        
        // Configure hosting view
        configureHostingView()
    }
    
    private func configureHostingView() {
        // Enable layer backing for better performance
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Ensure the view is properly sized
        hostingController.view.needsLayout = true
    }
    
    // MARK: - Public Methods
    /// Update the SwiftUI view content
    func updateRootView(_ newView: Content) {
        hostingController.rootView = newView
    }
    
    /// Get the current SwiftUI view
    var currentRootView: Content {
        return hostingController.rootView
    }
    
    // MARK: - Cleanup
    deinit {
        // Cleanup is automatically handled by the parent-child relationship
        // but this ensures proper cleanup if needed
        hostingController.removeFromParent()
    }
}
