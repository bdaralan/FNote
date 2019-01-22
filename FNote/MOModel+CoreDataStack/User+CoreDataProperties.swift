//
//  User+CoreDataProperties.swift
//  FNote
//
//  Created by Dara Beng on 1/21/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
}

// MARK: Generated accessors for collections
extension User {

    @objc(addCollectionsObject:)
    @NSManaged public func addToCollections(_ value: VocabularyCollection)

    @objc(removeCollectionsObject:)
    @NSManaged public func removeFromCollections(_ value: VocabularyCollection)

    @objc(addCollections:)
    @NSManaged public func addToCollections(_ values: NSSet)

    @objc(removeCollections:)
    @NSManaged public func removeFromCollections(_ values: NSSet)

}
