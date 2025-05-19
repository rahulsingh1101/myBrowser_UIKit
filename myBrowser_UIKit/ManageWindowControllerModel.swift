//
//  ManageWindowControllerModel.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

enum ManageWindowErrors: Error {
    case windowNotFound
}

final class ManageWindowControllerModel {
    var windowControllers: [BWWindowController] = []
    private var currentWindow: BWWindowController?
    
    func add(_ window: BWWindowController) {
        windowControllers.append(window)
        currentWindow = window
    }
    
    func remove() {
        windowControllers.removeAll {
            $0.identifier == currentWindow?.identifier
        }
        currentWindow = nil
    }
    
    func getCurrentWindow() -> BWWindowController? {
        return currentWindow
    }
}
