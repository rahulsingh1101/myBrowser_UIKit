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
//        let userService = CoreDataService<ToDoItem>()
//        let value = userService.fetch()
//        value.forEach {
//            print("debug :: isCompleted ::\($0.isCompleted)")
//            print("debug :: name ::\($0.name ?? "")")
//            print("debug :: family ::\($0.family ?? "")")
//        }
        
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
