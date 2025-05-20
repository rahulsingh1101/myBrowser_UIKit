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

        let contentView = ContentView() // your SwiftUI view
        let hostingController = NSHostingController(rootView: contentView)

        // Add hosting controller as child
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Set constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
