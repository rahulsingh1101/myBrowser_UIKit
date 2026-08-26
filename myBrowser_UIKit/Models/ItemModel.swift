//
//  ItemModel.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 19/05/25.
//

import Foundation

struct ItemModel: Codable {
    let title: String
    let subtitle: String
    let url: String
}

struct TaskCellModel {
    let title: String
    let subtitle: String
}

extension ItemModel {
    func toTaskModel() -> TaskCellModel {
        TaskCellModel(title: self.title, subtitle: self.subtitle)
    }
}
