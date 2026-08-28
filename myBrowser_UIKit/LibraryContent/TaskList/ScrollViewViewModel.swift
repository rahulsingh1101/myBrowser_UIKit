//
//  MyViewModel.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 21/05/25.
//

import Foundation

@MainActor
final class ScrollViewViewModel: ObservableObject {
    @Published var data: ListViewModel = .defaultValue

    func load() async {
        do {
            data = try await FirebaseJSONRepository.scrollViewData().load()
        } catch {
            data = .defaultValue
        }
    }
}
