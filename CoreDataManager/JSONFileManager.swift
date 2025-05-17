//
//  JSONFileManager.swift
//  CoreDataManager
//
//  Created by Rahul Singh on 17/05/25.
//

import Foundation

public class JSONFileManager<T: Codable> {
    
    private let fileName: String
    private var fileURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(fileName)
    }

    public init(fileName: String) {
        self.fileName = fileName
        createFileIfNeeded()
    }

    private func createFileIfNeeded() {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let emptyData = try JSONEncoder().encode([T]())
                try emptyData.write(to: fileURL)
            } catch {
                print("Failed to create file: \(error)")
            }
        }
    }

    // MARK: - Create
    public func add(_ item: T) {
        var items = getAll()
        items.append(item)
        save(items)
    }

    // MARK: - Read
    public func getAll() -> [T] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("Failed to read from file: \(error)")
            return []
        }
    }

    // MARK: - Update
//    func update(_ updatedItem: T) {
//        var items = getAll()
//        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
//            items[index] = updatedItem
//            save(items)
//        }
//    }

    // MARK: - Delete
//    func delete(_ item: T) {
//        var items = getAll()
//        items.removeAll { $0.id == item.id }
//        save(items)
//    }

    // MARK: - Save
    private func save(_ items: [T]) {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save to file: \(error)")
        }
    }

    // Optional: Clear All
    func clear() {
        save([])
    }
}
