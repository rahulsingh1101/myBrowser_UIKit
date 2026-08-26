//
//  Color+String.swift
//  TasksList
//
//  Created by Rahul Singh on 20/05/25.
//

import SwiftUI

extension String {
    func customColor() -> Color {
        switch self {
        case "P0":
            Color(red: 225/255, green: 45/255, blue: 69/255)
        case "P1":
            Color(red: 255/255, green: 111/255, blue: 97/255)
        case "P2":
            Color(red: 255/255, green: 187/255, blue: 60/255)
        case "P3":
            Color(red: 0/255, green: 168/255, blue: 107/255)
        case "P4":
            Color(red: 64/255, green: 156/255, blue: 255/255)
        case "P5":
            Color(red: 178/255, green: 190/255, blue: 195/255)
        case "no_value":
            Color(.brown)
        default:
            Color(.brown)
        }
    }
}
