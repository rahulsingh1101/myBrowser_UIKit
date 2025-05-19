//
//  BWWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

class BWWindowController: NSWindowController {
    let identifier: String
    weak var delegate: WindowDelegate?
    
    init(window: NSWindow, identifier: String) {
        self.identifier = identifier
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
