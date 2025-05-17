//
//  Person+CoreDataProperties.swift
//  CoreDataManager
//
//  Created by Rahul Singh on 17/05/25.
//

import Foundation
import CoreData

//extension SearchResult {
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchResult> {
//        return NSFetchRequest<SearchResult>(entityName: "SearchResult")
//    }
//}


extension SearchResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchResult> {
        return NSFetchRequest<SearchResult>(entityName: "SearchResult")
    }

//    @NSManaged public var testStr: String?
    @NSManaged public var searchUrl: String?

}

extension SearchResult : Identifiable {

}
