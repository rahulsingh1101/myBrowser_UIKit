//
//  AddItemCell.swift
//  myBrowser_UIKit
//

import Cocoa

protocol AddItemProtocol: AnyObject {
    func didTapAddItem()
}

final class AddItemCell: NSCollectionViewItem {
    weak var delegate: AddItemProtocol?
    private let plusButton = NSButton(title: "+", target: nil, action: nil)

    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.withAlphaComponent(0.1).cgColor
        view.layer?.cornerRadius = 8
        view.layer?.borderWidth = 1
        view.layer?.borderColor = NSColor.lightGray.withAlphaComponent(0.4).cgColor

        plusButton.font = .systemFont(ofSize: 24, weight: .medium)
        plusButton.isBordered = false
        plusButton.target = self
        plusButton.action = #selector(addTapped)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)

        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func addTapped() {
        delegate?.didTapAddItem()
    }
}
