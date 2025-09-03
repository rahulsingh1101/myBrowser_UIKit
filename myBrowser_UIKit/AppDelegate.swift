//
//  AppDelegate.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 17/05/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let windowFactory = AppWindowFactory()
    
    fileprivate func loadWindow(
        identifier: String,
        createWindowController: () -> RootWindowControllerProtocol
    ) {
        let controller = createWindowController()
        controller.showWindoww(self)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadWindow(identifier: #function) {
            return windowFactory.create(windowType: .main)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openNewWindow(sender)
        return false
    }
    
    private func openNewWindow(_ sender: NSApplication) {
        var minimizedWindow = windowFactory.windowTracker.getWindowForDockClick()
        if minimizedWindow == nil {
            minimizedWindow = windowFactory.create(windowType: .main)
        }
        minimizedWindow?.showWindoww(minimizedWindow)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return nil //CoreDataManager.shared.persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return .terminateNow
    }
}
