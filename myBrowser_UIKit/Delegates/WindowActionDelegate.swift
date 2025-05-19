//
//  WindowActionDelegate.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

protocol WindowActionDelegate: AnyObject {
    func windowWillClose(_ window: BWWindowController)
    func windowDidBecomekey(_ window: BWWindowController)
}
