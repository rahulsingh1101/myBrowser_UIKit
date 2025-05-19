//
//  PreloadWebsitesController.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import AppKit
import Cocoa

enum JSONLoadingError: Error {
    case fileNotFound
    case dataLoadingFailed
    case decodingFailed(Error)
}

final class PreloadWebsitesController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {
    var collectionView: NSCollectionView!
    
    var items: [ItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        setupCollectionView()
        switch loadItemsFromJSON() {
            
        case .success(let itemss):
            items = itemss
            collectionView.reloadData()
        case .failure(let failures):
            showAlert(for: failures)
        }
    }
    
    private func setupCollectionView() {
        // 1. Create ScrollView
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // 2. Create CollectionView
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 300, height: 100)
        layout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = NSCollectionView()
        collectionView.collectionViewLayout = layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isSelectable = true
        collectionView.register(PreloadItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("PreloadItem"))
        
        // 3. Embed in ScrollView
        scrollView.documentView = collectionView
        collectionView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let identifier = NSUserInterfaceItemIdentifier("PreloadItem")
        let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
        guard let collectionViewItem = item as? PreloadItem else { return item }
        collectionViewItem.configure(with: items[indexPath.item], indexPath: indexPath.item)
        collectionViewItem.delegate = self
        return collectionViewItem
    }
    
    func loadItemsFromJSON() -> Result<[ItemModel], JSONLoadingError> {
        guard let url = Bundle.main.url(forResource: "PreloadWebsitesController", withExtension: "json") else {
            print("❌ Error: Could not find data.json in the bundle.")
            return .failure(JSONLoadingError.fileNotFound)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let items = try JSONDecoder().decode([ItemModel].self, from: data)
            return .success(items)
        } catch let error as DecodingError {
            print("❌ JSON Decoding Error: \(error.localizedDescription)")
            var message = "❌ JSON Decoding Error: \(error.localizedDescription)"
            
            switch error {
            case .typeMismatch(let type, let context):
                print("  ➤ Type '\(type)' mismatch:", context.debugDescription)
                message = "  ➤ Type '\(type)' mismatch:: context::\(context.debugDescription)"
            case .valueNotFound(let type, let context):
                print("  ➤ Value '\(type)' not found:", context.debugDescription)
                message = "  ➤ Value '\(type)' not found:: context::\(context.debugDescription)"
            case .keyNotFound(let key, let context):
                print("  ➤ Key '\(key)' not found:", context.debugDescription)
                message = "  ➤ Key '\(key)' not found:: context::\(context.debugDescription)"
            case .dataCorrupted(let context):
                print("  ➤ Data corrupted:", context.debugDescription)
                message = "  ➤ Data corrupted:: context::\(context.debugDescription)"
            default:
                print("  ➤ Unknown decoding error")
                message = "  ➤ Unknown decoding error"
            }
            print("❌ JSON Decoding Error: \(error.localizedDescription)")
            let errorr = NSError(domain: "com.myapp.data", code: 404, userInfo: [NSLocalizedDescriptionKey: message])
            return .failure(JSONLoadingError.decodingFailed(errorr))
        } catch {
            print("❌ Other Error: \(error.localizedDescription)")
            return .failure(JSONLoadingError.decodingFailed(error))
        }
    }
    
    func showAlert(for error: Error, in window: NSWindow? = nil) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "An Error Occurred"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            if let window {
                alert.beginSheetModal(for: window) { response in
                    print("debug :: response:: \(response)")
                }
            } else {
                alert.runModal()
            }
        }
    }
}

extension PreloadWebsitesController: OpenUrlProtocol {
    func openAt(_ index: Int?) {
        if let index {
            let item = items[index]
            let appDelegate = NSApplication.shared.delegate as? AppDelegate
            appDelegate?.openNewWindow(identifier: item.url, url: item.url)
        }
    }
}
