//
//  RealtimeDatabaseStore.swift
//  myBrowser_UIKit
//

import FirebaseDatabase
import Foundation

enum RealtimeDatabaseError: Error {
    case noData
}

protocol DataStoring {
    func read<T: Decodable>(at path: String, as type: T.Type) async throws -> T
    func write<T: Encodable>(_ value: T, at path: String) async throws
}

final class RealtimeDatabaseStore: DataStoring {
    static let shared = RealtimeDatabaseStore()

    private let database = Database.database()

    private init() {}

    func read<T: Decodable>(at path: String, as type: T.Type) async throws -> T {
        let snapshot: DataSnapshot = try await withCheckedThrowingContinuation { continuation in
            database.reference(withPath: path).getData { error, snapshot in
                if let error {
                    continuation.resume(throwing: error)
                } else if let snapshot {
                    continuation.resume(returning: snapshot)
                } else {
                    continuation.resume(throwing: RealtimeDatabaseError.noData)
                }
            }
        }
        guard let value = snapshot.value, !(value is NSNull) else {
            throw RealtimeDatabaseError.noData
        }
        let data = try JSONSerialization.data(withJSONObject: value)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func write<T: Encodable>(_ value: T, at path: String) async throws {
        let data = try JSONEncoder().encode(value)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            database.reference(withPath: path).setValue(jsonObject) { error, _ in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
