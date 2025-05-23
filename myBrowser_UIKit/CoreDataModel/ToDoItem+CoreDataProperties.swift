//
//  ToDoItem+CoreDataProperties.swift
//  
//
//  Created by Rahul Singh on 23/05/25.
//
//

import Foundation
import CoreData


extension ToDoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoItem> {
        return NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
    }

    @NSManaged public var isCompleted: Bool
    @NSManaged public var name: String?
    @NSManaged public var priority: String?

}

extension ToDoItem {
    var priorityType: Priority {
        get {
            guard let priority else { return .no_value }
            guard let value = Priority(rawValue: priority) else {
                return .no_value
            }
            return value
        }
        set {
            priority = newValue.rawValue
        }
    }
}

enum Priority: String {
    case P0
    case P1
    case P2
    case P3
    case P4
    case P5
    case no_value
}
