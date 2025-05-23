//
//  Model.swift
//  TasksList
//
//  Created by Rahul Singh on 20/05/25.
//

import Foundation

struct ListViewModel: Codable {
    let scrollView: [BoxViewModel]
    let boxView: BoxViewModel

    enum CodingKeys: String, CodingKey {
        case scrollView = "ScrollView"
        case boxView = "BoxView"
    }
    
    static let defaultValue = ListViewModel(scrollView: [], boxView: .init(title: "", items: []))
}

struct BoxViewModel: Codable, Identifiable, RandomAccessCollection {
    private(set) var id = UUID()
    let title: String
    let items: [GroupItem]
    
    // MARK: - Collection Conformance
    
    typealias Index = Int
    typealias Element = GroupItem
    
    var startIndex: Int { items.startIndex }
    var endIndex: Int { items.endIndex }
    
    subscript(position: Int) -> GroupItem {
        items[position]
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case title, items
    }
}

struct GroupItem: Identifiable, Codable {
    private(set) var id = UUID()
    let title: String
    
    private enum CodingKeys: String, CodingKey {
        case title
    }
}
