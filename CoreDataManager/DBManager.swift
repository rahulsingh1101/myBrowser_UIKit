//
//  DBManager.swift
//  CoreDataManager
//
//  Created by Rahul Singh on 17/05/25.
//

import Foundation
import CoreData

//public final class DBManager {
//    static var persistentContainer: NSPersistentContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = PersistentContainerLoader.loadContainer()
////        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
////            if let error = error as NSError? {
////                // Replace this implementation with code to handle the error appropriately.
////                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
////                 
////                /*
////                 Typical reasons for an error here include:
////                 * The parent directory does not exist, cannot be created, or disallows writing.
////                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
////                 * The device is out of space.
////                 * The store could not be migrated to the current model version.
////                 Check the error message to determine what the actual problem was.
////                 */
////                fatalError("Unresolved error \(error), \(error.userInfo)")
////            }
////        })
//        return container
//    }()
//    
//    private static var managedObjectContext: NSManagedObjectContext {
//        return persistentContainer.viewContext
//    }
//    
//    public class func create<E>(proccess: (_ object: E) -> Void) {
//        do {
////            let searchResult = SearchResult(context: managedObjectContext)
////            proccess(NSEntityDescription.insertNewObject(forEntityName: "\(E.self)", into: managedObjectContext) as! E)
//            proccess(NSEntityDescription.insertNewObject(forEntityName: "\(E.self)", into: managedObjectContext) as! E)
//
//            try managedObjectContext.save()
//        }
//        catch let error {
//            fatalError(error.localizedDescription)
//        }
//    }
//    
//    public class func read<E>(proccess: ((_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Void)?) -> [E] {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(E.self)")
//        
//        proccess?(fetchRequest)
//        
//        do {
//            return try managedObjectContext.fetch(fetchRequest) as! [E]
//        }
//        catch let error {
//            fatalError(error.localizedDescription)
//        }
//    }
//    
//    public class func update<E>(proccess: ((_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Void)?, update: (_ objects: [E]) -> Void) -> Bool {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(E.self)")
//        
//        proccess?(fetchRequest)
//        
//        do {
//            update(try managedObjectContext.fetch(fetchRequest) as! [E])
//            try managedObjectContext.save()
//            
//            return true
//        }
//        catch let error {
//            fatalError(error.localizedDescription)
//        }
//        
//        return false
//    }
//    
//    public class func delete<E>(proccess: ((_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Void)?, deletedObjects: ((_ objects: [E]) -> Void)?) -> Bool {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(E.self)")
//        
//        do {
//            let objects = try managedObjectContext.fetch(fetchRequest) as! [E]
//
//            deletedObjects?(objects)
//            
//            for object in objects {
//                managedObjectContext.delete(object as! NSManagedObject)
//            }
//            
//            try managedObjectContext.save()
//            
//            return true
//        }
//        catch let error {
//            fatalError(error.localizedDescription)
//        }
//        
//        return false
//    }
//    
//}
