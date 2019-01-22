//
//  VocabularyCollection+CoreDataProperties.swift
//  FNote
//
//  Created by Dara Beng on 1/21/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


extension VocabularyCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyCollection> {
        return NSFetchRequest<VocabularyCollection>(entityName: "VocabularyCollection")
    }
}

// MARK: Generated accessors for vocabularies
extension VocabularyCollection {

    @objc(addVocabulariesObject:)
    @NSManaged public func addToVocabularies(_ value: Vocabulary)

    @objc(removeVocabulariesObject:)
    @NSManaged public func removeFromVocabularies(_ value: Vocabulary)

    @objc(addVocabularies:)
    @NSManaged public func addToVocabularies(_ values: NSSet)

    @objc(removeVocabularies:)
    @NSManaged public func removeFromVocabularies(_ values: NSSet)

}
