//
//  TaskGridViewModel.swift
//  myBrowser_UIKit
//

import Foundation

final class TaskGridViewModel: ObservableObject {
    @Published var items: [ItemModel] = []
}
