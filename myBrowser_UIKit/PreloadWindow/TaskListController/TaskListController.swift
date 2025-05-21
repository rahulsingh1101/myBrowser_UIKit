//
//  TaskListController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 20/05/25.
//

import Cocoa
import SwiftUI

final class TaskListController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let contentView = ContentView()
        let hostingController = NSHostingController(rootView: contentView)

        // Add hosting controller as child
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Set constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingController.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hostingController.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
