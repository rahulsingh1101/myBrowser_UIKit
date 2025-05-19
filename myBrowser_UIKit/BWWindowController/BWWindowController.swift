//
//  BWWindowController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

protocol BWWindowControllerProtocol: AnyObject {
    var identifier: String { get }
    var delegate: WindowActionDelegate? { get set }
    func showWindoww(_ sender: Any?)
}

class BWWindowController: NSWindowController, BWWindowControllerProtocol, NSWindowDelegate {
    let identifier: String
    weak var delegate: WindowActionDelegate?
    
    init(window: NSWindow, identifier: String) {
        self.identifier = identifier
        super.init(window: window)
        self.window?.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func windowWillClose(_ notification: Notification) {
        delegate?.windowWillClose(self)
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        delegate?.windowDidBecomekey(self)
    }
    
    func showWindoww(_ sender: Any?) {
        showWindow(sender)
    }
}
