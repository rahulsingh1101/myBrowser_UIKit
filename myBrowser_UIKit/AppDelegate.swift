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
    var windowController: BWWindowControllerProtocol!
    private let manageWindow = ManageWindowControllerModel()
    
    fileprivate func loadWindow(
        identifier: String,
        createWindowController: () -> BWWindowControllerProtocol
    ) {
        let (isWindowAlreadyPresent, windowWithId) = manageWindow.isWindowAlreadyPresent(identifier)
        
        if !isWindowAlreadyPresent {
            let controller = createWindowController()
            controller.delegate = self
            controller.showWindoww(self)
            manageWindow.add(controller)
            windowController = controller
        } else if let windowWithId {
            windowWithId.showWindoww(self)
            manageWindow.updateCurrentWindow(windowWithId)
            windowController.reloadURL()
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadWindow(identifier: #function) {
            return PreloadWindowController(identifier: NSUserInterfaceItemIdentifier(#function).rawValue, title: "Search / Bookmark - 1")
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openNewWindow(sender)
        return false
    }
    
    func openNewWindow(_ sender: NSApplication) {
        let currentWindowIdentifier = manageWindow.getCurrentWindow()?.identifier
        let windows = sender.windows.compactMap {
            $0.windowController as? PreloadWindowController
        }.first {
            $0.identifier == currentWindowIdentifier
        }
        if windows == nil {
            loadWindow(identifier: #function) {
                return PreloadWindowController(identifier: NSUserInterfaceItemIdentifier(#function).rawValue, title: "Search / Bookmark - 2")
            }
        }
    }
    
    func openUrlLoadingWindow(identifier: String, model: UrlLoadingViewController.Model) {
        loadWindow(identifier: identifier) {
            return UrlLoadingWindowController(identifier: NSUserInterfaceItemIdentifier(identifier).rawValue, model: .init(urlToLoad: model.urlToLoad, title: model.title))
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return CoreDataManager.shared.persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

extension AppDelegate: WindowActionDelegate {
    func windowWillClose(_ window: BWWindowController) {
        manageWindow.remove(window)
    }
    
    func windowDidBecomekey(_ window: BWWindowController) {
        manageWindow.updateCurrentWindow(window)
    }
}
