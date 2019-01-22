//
//  Vocabulary+CoreDataProperties.swift
//  FNote
//
//  Created by Dara Beng on 1/21/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


extension Vocabulary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vocabulary> {
        return NSFetchRequest<Vocabulary>(entityName: "Vocabulary")
    }
}

// MARK: Generated accessors for alternatives
extension Vocabulary {

    @objc(addAlternativesObject:)
    @NSManaged public func addToAlternatives(_ value: Vocabulary)

    @objc(removeAlternativesObject:)
    @NSManaged public func removeFromAlternatives(_ value: Vocabulary)

    @objc(addAlternatives:)
    @NSManaged public func addToAlternatives(_ values: NSSet)

    @objc(removeAlternatives:)
    @NSManaged public func removeFromAlternatives(_ values: NSSet)

}

// MARK: Generated accessors for relations
extension Vocabulary {

    @objc(addRelationsObject:)
    @NSManaged public func addToRelations(_ value: Vocabulary)

    @objc(removeRelationsObject:)
    @NSManaged public func removeFromRelations(_ value: Vocabulary)

    @objc(addRelations:)
    @NSManaged public func addToRelations(_ values: NSSet)

    @objc(removeRelations:)
    @NSManaged public func removeFromRelations(_ values: NSSet)

}
