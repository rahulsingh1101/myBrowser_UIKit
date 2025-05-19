//
//  ItemCollectionViewItem.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Cocoa

class ItemCollectionViewItem: NSCollectionViewItem {
    private let titleLabel = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private let openButton = NSButton(title: "Open", target: nil, action: nil)
    
    private var itemURL: String?
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.withAlphaComponent(0.2).cgColor
        view.layer?.cornerRadius = 8
        
        titleLabel.font = .boldSystemFont(ofSize: 14)
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.lineBreakMode = .byTruncatingTail
        
        openButton.target = self
        openButton.action = #selector(openURL)
        
        [titleLabel, subtitleLabel, openButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    @objc private func openURL() {
        guard let itemURL = itemURL, let url = URL(string: itemURL) else { return }
        NSWorkspace.shared.open(url)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            openButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            openButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            openButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with item: ItemModel) {
        titleLabel.stringValue = item.title
        subtitleLabel.stringValue = item.subtitle
        itemURL = item.url
    }
}
