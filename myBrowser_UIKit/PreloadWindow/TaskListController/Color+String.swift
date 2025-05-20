//
//  Color+String.swift
//  TasksList
//
//  Created by Rahul Singh on 20/05/25.
//

import SwiftUI

extension String {
    func customColor() -> Color {
        switch self.lowercased() {
        case "red":
            return Color(red: 139/255, green: 0, blue: 0)
        case "green":
            return Color(red: 0, green: 100/255, blue: 0)
        case "blue":
            return .blue
        case "pink":
            return Color(red: 255/225, green: 192/255, blue: 203/255)
        default:
            return .gray
        }
    }
}
