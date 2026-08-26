//
//  MyViewModel.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 21/05/25.
//

import Foundation

final class ScrollViewViewModel: ObservableObject {
    @Published var data: ListViewModel = ListViewModel.defaultValue
}
