//
//  LabelWithSpacer.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 21/05/25.
//

import SwiftUI

struct LabelWithSpacer: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
            Spacer()
        }
    }
}
