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
                                .foregroundColor(group.borderColor.customColor())
                                .padding(.horizontal, 8)
                                .onTapGesture {
                                    print("debug :: onTapGesture ::\(item.title)")
                                }
                        }
                    }
                    .borderColor(group.borderColor)
                    .padding(.horizontal)
                }
                BoxView {
                    ForEach(viewModel.data.boxView) { item in
                        LabelWithSpacer(text: item.title)
                            .foregroundColor(viewModel.data.boxView.borderColor.customColor())
                            .padding(.horizontal, 8)
                            .onTapGesture {
                                print("debug :: onTapGesture ::\(item.title)")
                            }
                    }
                }
                .borderColor(viewModel.data.boxView.borderColor)
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
