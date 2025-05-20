//
//  ViewModel.swift
//  TasksList
//
//  Created by Rahul Singh on 20/05/25.
//

import Foundation

func loadGroupBoxes() -> [GroupBox] {
    guard let url = Bundle.main.url(forResource: "data", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let groupBoxes = try? JSONDecoder().decode([GroupBox].self, from: data) else {
        return []
    }
    return groupBoxes
}
