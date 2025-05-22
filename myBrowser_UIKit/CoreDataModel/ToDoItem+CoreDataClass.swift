//
//  ToDoItem+CoreDataClass.swift
//  
//
//  Created by Rahul Singh on 22/05/25.
//
//

import Foundation
import CoreData


public class ToDoItem: NSManagedObject {
    var userType: ItemFamily {
        get {
            ItemFamily(rawValue: family ?? "") ?? .guest
        }
        set {
            family = newValue.rawValue
        }
    }
}

enum ItemFamily: String {
    case gold
    case diamond
    case leasure
    case guest
}
