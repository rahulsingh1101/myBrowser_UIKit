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
    @State private var groupBoxes: [GroupBox] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(groupBoxes) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(group.items) { item in
                            HStack {
                                Text(item.title)
                                    .foregroundColor(group.borderColor.customColor())
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .padding()
                    .background(group.borderColor.customColor().opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(group.borderColor.customColor(), lineWidth: 2)
                    )
                    .shadow(color: group.borderColor.customColor().opacity(0.4), radius: 4)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            groupBoxes = loadGroupBoxes()
        }
    }
}
