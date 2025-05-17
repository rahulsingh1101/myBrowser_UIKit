
import Foundation
import CoreData

//let resourceBundle = Bundle(for: CoreDataManagerrr.self).url(forResource: "CoreDataManagerResources", withExtension: "bundle").flatMap { Bundle(url: $0) }

//guard let modelURL = resourceBundle?.url(forResource: "YourModelName", withExtension: "momd"),
//      let model = NSManagedObjectModel(contentsOf: modelURL) else {
//    fatalError("Failed to load model from resource bundle")
//}

//public final class CoreDataManagerrr {
//    public let context: NSManagedObjectContext
//
//    public init(context: NSManagedObjectContext) {
//        self.context = context
//    }
//
//    // MARK: - Create
//    public func createObject<T: NSManagedObject>(of type: T.Type) -> T {
//        let entityName = String(describing: type)
//        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
//            fatalError("❌ Entity \(entityName) not found in Core Data model")
//        }
//
//        guard let object = T(entity: entity, insertInto: context) as? T else {
//            fatalError("❌ Failed to cast created object to \(T.self)")
//        }
//
//        return object
//    }
//
//    // MARK: - Fetch All
////    public func fetchObjects<T: NSManagedObject>(predicate: NSPredicate? = nil,
////                                                 sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
////        let entityName = String(describing: T.self)
////        let request = NSFetchRequest<T>(entityName: entityName)
////        request.predicate = predicate
////        request.sortDescriptors = sortDescriptors
////
////        do {
////            return try context.fetch(request)
////        } catch {
////            print("❌ Fetch failed: \(error)")
////            return []
////        }
////    }
//
//    // MARK: - Delete
//    public func deleteObject<T: NSManagedObject>(_ object: T) {
//        context.delete(object)
//    }
//
//    // MARK: - Save
//    public func saveContext() {
//        guard context.hasChanges else { return }
//        do {
//            try context.save()
//            print("✅ Context saved.")
//        } catch {
//            print("❌ Failed to save context: \(error)")
//        }
//    }
//}

//public final class CoreDataManager {
//    public static let shared = CoreDataManager()
//
////    private let persistentContainer: NSPersistentContainer
////    PersistentContainerLoader.loadContainer(named: "CoreDataModel")
//
//    lazy var persistentContainer: NSPersistentContainer = {
//        let persistentContainer = PersistentContainerLoader.loadContainer()
//        return persistentContainer
//    }()
//
//    public var context: NSManagedObjectContext {
//        return persistentContainer.viewContext
//    }
//
//    // MARK: - Create
////    public func createObject<T: NSManagedObject>(for type: T.Type) -> T? {
////        guard let name = T.entity().name else { return nil }
////        return NSEntityDescription.insertNewObject(forEntityName: name, into: context) as? T
////    }
//
////    public func createObject<T: NSManagedObject>(of type: T.Type) -> T {
////        let entityName = String(describing: type)
////        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
////            fatalError("❌ Entity \(entityName) not found in Core Data model")
////        }
////
////        let object = T(entity: entity, insertInto: context)
////        return object
////    }
//
//    public func createObject<T: NSManagedObject>(of type: T.Type) -> T {
//        let object = T(context: context)
//        return object
//    }
//
//    // MARK: - Read
////    public func fetchObjects<T>(of request: NSFetchRequest<T>,
////                                          predicate: NSPredicate? = nil,
////                                          sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
//////        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
////        request.predicate = predicate
////        request.sortDescriptors = sortDescriptors
////
////        do {
////            return try context.fetch(request)
////        } catch {
////            print("❌ Fetch failed: \(error)")
////            return []
////        }
////    }
//
////    public func fetchObjects<T: NSManagedObject>(
//////        for type: T.Type,
////        predicate: NSPredicate? = nil,
////        sortDescriptors: [NSSortDescriptor]? = nil
////    ) -> [T] {
//////        let request = T.fetchRequest()
////        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
////        request.predicate = predicate
////        request.sortDescriptors = sortDescriptors
////
////        do {
////            return try context.fetch(request)
////        } catch {
////            print("Fetch error: \(error)")
////            return []
////        }
////    }
//
////    public func fetchObjects(
////        predicate: NSPredicate? = nil,
////        sortDescriptors: [NSSortDescriptor]? = nil
////    ) -> [SearchResult] {
////        let request = SearchResult.fetchRequest()
////        request.predicate = predicate
////        request.sortDescriptors = sortDescriptors
////
////        do {
////            return try context.fetch(request)
////        } catch {
////            print("Fetch error: \(error)")
////            return []
////        }
////    }
//
//    // MARK: - Update
//    public func saveContext() {
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                print("Save error: \(error)")
//            }
//        }
//    }
//
//    // MARK: - Delete
//    public func deleteObject(_ object: NSManagedObject) {
//        context.delete(object)
//        saveContext()
//    }
//}

//import CoreData

//public class PersistentContainerLoader {
//    public static func loadContainer(modelName: String = "my-BrowserModel") -> NSPersistentContainer {
//        // Find the compiled .momd file in the bundle
//        guard let bundleURL = Bundle(for: CoreDataManagerrr.self).url(forResource: "CoreDataManagerResources", withExtension: "bundle"), let bundle = Bundle(url: bundleURL) else {
//            fatalError("❌ Could not find CoreDataManagerResources file for model named \(modelName)")
//        }
//
//        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd") else {
//            fatalError("❌ Could not find .momd file for model named \(modelName) in bundle \(bundle.bundleURL)")
//        }
//
//        // Create the managed object model
//        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("❌ Could not load managed object model from \(modelURL)")
//        }
//
//        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
//        container.loadPersistentStores { desc, error in
//            if let error = error {
//                fatalError("❌ Failed to load persistent store: \(error)")
//            }
//        }
//
//        return container
//    }
//    
//    public static var persistentContainer: NSPersistentContainer = {
//        let persistentContainer = PersistentContainerLoader.loadContainer()
//        return persistentContainer
//    }()
//}

