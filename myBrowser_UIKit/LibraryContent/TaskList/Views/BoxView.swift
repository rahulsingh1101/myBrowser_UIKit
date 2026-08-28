//
//  BoxView.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 21/05/25.
//

import Foundation

import SwiftUI

struct BoxView<Content: View>: View {
    var borderColor: String = "pink"
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding()
        .background(borderColor.customColor().opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor.customColor(), lineWidth: 2)
        )
        .shadow(color: borderColor.customColor().opacity(0.4), radius: 4)
    }
    
    // MARK: - Modifier
    func borderColor(_ colorName: String) -> Self {
        var copy = self
        copy.borderColor = colorName
        return copy
    }
}
