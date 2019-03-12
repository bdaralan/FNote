//
//  VocabularyConnection+CoreDataProperties.swift
//  FNote
//
//  Created by Dara Beng on 3/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


extension VocabularyConnection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyConnection> {
        return NSFetchRequest<VocabularyConnection>(entityName: "VocabularyConnection")
    }
}

// MARK: Generated accessors for vocabularies
extension VocabularyConnection {

    @objc(addVocabulariesObject:)
    @NSManaged public func addToVocabularies(_ value: Vocabulary)

    @objc(removeVocabulariesObject:)
    @NSManaged public func removeFromVocabularies(_ value: Vocabulary)

    @objc(addVocabularies:)
    @NSManaged public func addToVocabularies(_ values: NSSet)

    @objc(removeVocabularies:)
    @NSManaged public func removeFromVocabularies(_ values: NSSet)

}
