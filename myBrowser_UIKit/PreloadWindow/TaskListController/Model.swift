//
//  Model.swift
//  TasksList
//
//  Created by Rahul Singh on 20/05/25.
//

import Foundation

struct GroupItem: Identifiable, Codable {
    private(set) var id = UUID()
    let title: String
    
    private enum CodingKeys: String, CodingKey {
        case title
    }
}

struct GroupBox: Identifiable, Codable {
    private(set) var id = UUID()
    let title: String
    let borderColor: String
    let items: [GroupItem]
    
    private enum CodingKeys: String, CodingKey {
        case title, borderColor, items
    }
}
