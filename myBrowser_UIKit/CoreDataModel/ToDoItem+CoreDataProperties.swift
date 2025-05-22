//
//  ToDoItem+CoreDataProperties.swift
//  
//
//  Created by Rahul Singh on 22/05/25.
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
    @NSManaged public var family: String?

}
