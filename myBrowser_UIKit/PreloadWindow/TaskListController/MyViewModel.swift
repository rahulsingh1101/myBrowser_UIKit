//
//  MyViewModel.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 21/05/25.
//

import Foundation

class MyViewModel: ObservableObject {
    @Published var data: ListViewModel = ListViewModel.defaultValue
    
    private var isLoaded = false
    
    func loadDataIfNeeded() {
        guard !isLoaded else {
            data = ListViewModel.defaultValue
            return
        }
        isLoaded = true
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let groupBoxes = try? JSONDecoder().decode(ListViewModel.self, from: data) else {
            data = ListViewModel.defaultValue
            return
        }
        self.data = groupBoxes
    }
}
