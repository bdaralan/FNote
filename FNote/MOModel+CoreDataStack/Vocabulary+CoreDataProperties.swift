//
//  Vocabulary+CoreDataProperties.swift
//  FNote
//
//  Created by Dara Beng on 3/9/19.
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

// MARK: Generated accessors for sourceOf
extension Vocabulary {

    @objc(addSourceOfObject:)
    @NSManaged public func addToSourceOf(_ value: VocabularyConnection)

    @objc(removeSourceOfObject:)
    @NSManaged public func removeFromSourceOf(_ value: VocabularyConnection)

    @objc(addSourceOf:)
    @NSManaged public func addToSourceOf(_ values: NSSet)

    @objc(removeSourceOf:)
    @NSManaged public func removeFromSourceOf(_ values: NSSet)

}

// MARK: Generated accessors for targetOf
extension Vocabulary {

    @objc(addTargetOfObject:)
    @NSManaged public func addToTargetOf(_ value: VocabularyConnection)

    @objc(removeTargetOfObject:)
    @NSManaged public func removeFromTargetOf(_ value: VocabularyConnection)

    @objc(addTargetOf:)
    @NSManaged public func addToTargetOf(_ values: NSSet)

    @objc(removeTargetOf:)
    @NSManaged public func removeFromTargetOf(_ values: NSSet)

}

// MARK: Generated accessors for connections
extension Vocabulary {

    @objc(addConnectionsObject:)
    @NSManaged public func addToConnections(_ value: VocabularyConnection)

    @objc(removeConnectionsObject:)
    @NSManaged public func removeFromConnections(_ value: VocabularyConnection)

    @objc(addConnections:)
    @NSManaged public func addToConnections(_ values: NSSet)

    @objc(removeConnections:)
    @NSManaged public func removeFromConnections(_ values: NSSet)

}
