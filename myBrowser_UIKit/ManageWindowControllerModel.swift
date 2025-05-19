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
    
    func remove(_ window: BWWindowController) {
        windowControllers.removeAll {
            $0.identifier == window.identifier
        }
        currentWindow = nil
    }
    
    func getCurrentWindow() -> BWWindowController? {
        return currentWindow
    }
    
    func isWindowAlreadyPresent(_ identifier: String) -> (isPresent: Bool, window: BWWindowController?) {
        let value = windowControllers.first {
            $0.identifier == identifier
        }
        return (value != nil, value)
    }
    
    func updateCurrentWindow(_ window: BWWindowController) {
        if currentWindow?.identifier == window.identifier {
            return
        }
        let value = windowControllers.first {
            $0.identifier == window.identifier
        }
        currentWindow = value
    }
}
