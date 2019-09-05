//
//  NoteCard+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class NoteCard: NSManagedObject, ObjectValidatable {
    
    @NSManaged var navtive: String
    @NSManaged var translation: String
    @NSManaged var isFavorited: Bool
    @NSManaged var note: String
    @NSManaged var collection: NoteCardCollection?
    @NSManaged var relationships: Set<NoteCard>
    @NSManaged var tags: Set<Tag>
    
    @NSManaged private var formalityValue: Int64
    
    var formality: Formality {
        set { formalityValue = newValue.rawValue }
        get { Formality(rawValue: formalityValue)! }
    }
    
    enum Formality: Int64 {
        case unknown
        case informal
        case neutral
        case formal
    }
}


extension NoteCard {
    
    func isValid() -> Bool {
        hasValidInputs() && collection != nil
    }
    
    func hasValidInputs() -> Bool {
        !navtive.trimmed().isEmpty && !translation.trimmed().isEmpty
    }
    
    func hasChangedValues() -> Bool {
        hasPersistentChangedValues
    }
}


extension NoteCard {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<NoteCard> {
        return NSFetchRequest<NoteCard>(entityName: "NoteCard")
    }
    
    @objc(addRelationshipsObject:)
    @NSManaged public func addToRelationships(_ value: NoteCard)
    
    @objc(removeRelationshipsObject:)
    @NSManaged public func removeFromRelationships(_ value: NoteCard)
    
    @objc(addRelationships:)
    @NSManaged public func addToRelationships(_ values: NSSet)
    
    @objc(removeRelationships:)
    @NSManaged public func removeFromRelationships(_ values: NSSet)
    
}


extension NoteCard {
    
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)
    
    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)
    
    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)
    
    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
    
}
