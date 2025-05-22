//
//  CoreDataService.swift
//  myBrowser_UIKit
//
//  Created by Rahul Singh on 22/05/25.
//

import Foundation
import CoreData

class CoreDataService<T: NSManagedObject> {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    // Create
    func create(configure: (T) -> Void) -> T? {
        let entityName = String(describing: T.self)
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? T else {
            return nil
        }
        configure(entity)
        save()
        return entity
    }
    
    // Read
    func fetch(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request) as? [T] ?? []
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }

    // Update is done on fetched object by modifying properties and saving context

    // Delete
    func delete(_ object: T) {
        context.delete(object)
        save()
    }

    // Save
    private func save() {
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Save failed: \(error)")
        }
    }
}
