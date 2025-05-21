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
            return Color(red: 255/255, green: 105/255, blue: 97/255)
        case "green":
            return Color(red: 152/255, green: 255/255, blue: 152/255)
        case "blue":
            return .blue
        case "pink":
            return Color(red: 255/225, green: 192/255, blue: 203/255)
        case "orange":
            return Color(red: 255/225, green: 171/255, blue: 91/255)
        default:
            return .gray
        }
    }
}
