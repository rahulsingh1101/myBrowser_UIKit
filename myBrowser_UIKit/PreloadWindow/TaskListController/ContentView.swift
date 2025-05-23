//
//  ContentView.swift
//  TasksList
//
//  Created by Rahul Singh on 20/05/25.
//

import SwiftUI
import SwiftData
import Cocoa

struct ContentView: View {
    @StateObject private var viewModel: MyViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: MyViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.data.scrollView) { group in
                    BoxView {
                        ForEach(group.items) { item in
                            LabelWithSpacer(text: item.title)
                                .foregroundColor(group.title.customColor())
                                .padding(.horizontal, 8)
                                .onTapGesture {
                                    print("debug :: onTapGesture ::\(item.title)")
                                }
                        }
                    }
                    .borderColor(group.title)
                    .padding(.horizontal)
                }
                BoxView {
                    ForEach(viewModel.data.boxView) { item in
                        LabelWithSpacer(text: item.title)
                            .foregroundColor(viewModel.data.boxView.title.customColor())
                            .padding(.horizontal, 8)
                            .onTapGesture {
                                print("debug :: onTapGesture ::\(item.title)")
//                                let userService = CoreDataService<ToDoItem>()
//                                let newUser = userService.create { user in
//                                    user.name = "Prompt Engineering"
//                                    user.family = ItemFamily.diamond.rawValue
//                                    user.isCompleted = false
//                                }
                            }
                    }
                }
                .borderColor(viewModel.data.boxView.title)
                .padding(.horizontal)
                .onTapGesture {
                    print("debug :: onTapGesture BoxView")
                }
            }
            .padding(.vertical)
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewModel.loadDataIfNeeded()
        }
    }
}
