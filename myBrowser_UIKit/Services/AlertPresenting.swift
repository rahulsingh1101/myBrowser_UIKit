//
//  AlertPresenting.swift
//  myBrowser_UIKit
//

import AppKit

protocol AlertPresenting {
    func presentWebsitePrompt(editing existing: ItemModel?, in window: NSWindow, onSubmit: @escaping (ItemModel) -> Void)
    func presentDeleteConfirmation(title: String, in window: NSWindow, onConfirm: @escaping () -> Void)
    func presentError(_ error: Error, in window: NSWindow?)
}

@MainActor
final class AlertPresenter: AlertPresenting {
    func presentWebsitePrompt(editing existing: ItemModel?, in window: NSWindow, onSubmit: @escaping (ItemModel) -> Void) {
        let alert = NSAlert()
        alert.messageText = existing == nil ? "Add Website" : "Edit Website"
        alert.addButton(withTitle: existing == nil ? "Add" : "Save")
        alert.addButton(withTitle: "Cancel")

        let titleField = NSTextField(string: existing?.title ?? "")
        titleField.placeholderString = "Title"
        let subtitleField = NSTextField(string: existing?.subtitle ?? "")
        subtitleField.placeholderString = "Subtitle"
        let urlField = NSTextField(string: existing?.url ?? "")
        urlField.placeholderString = "URL"

        let stack = NSStackView(views: [titleField, subtitleField, urlField])
        stack.orientation = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 90))
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        [titleField, subtitleField, urlField].forEach {
            $0.widthAnchor.constraint(equalToConstant: 260).isActive = true
        }

        alert.accessoryView = container

        alert.beginSheetModal(for: window) { response in
            guard response == .alertFirstButtonReturn else { return }
            let submitted = ItemModel(
                title: titleField.stringValue,
                subtitle: subtitleField.stringValue,
                url: urlField.stringValue
            )
            onSubmit(submitted)
        }
    }

    func presentDeleteConfirmation(title: String, in window: NSWindow, onConfirm: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = title
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: window) { response in
            guard response == .alertFirstButtonReturn else { return }
            onConfirm()
        }
    }

    func presentError(_ error: Error, in window: NSWindow?) {
        let alert = NSAlert()
        alert.messageText = "An Error Occurred"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        if let window {
            alert.beginSheetModal(for: window)
        } else {
            alert.runModal()
        }
    }
}
