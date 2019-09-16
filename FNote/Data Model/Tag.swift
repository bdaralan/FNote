//
//  Tag+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class Tag: NSManagedObject, ObjectValidatable {
    
    @NSManaged var name: String
    @NSManaged var noteCards: Set<NoteCard>
    
    
    override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        objectWillChange.send()
    }
}


extension Tag {
    
    func isValid() -> Bool {
        hasValidInputs()
    }
    
    func hasValidInputs() -> Bool {
        !name.trimmed().isEmpty
    }
    
    func hasChangedValues() -> Bool {
        hasPersistentChangedValues
    }
    
    func validateData() {
        name = name.trimmed()
    }
}


extension Tag {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @objc(addNoteCardsObject:)
    @NSManaged func addToNoteCards(_ value: NoteCard)

    @objc(removeNoteCardsObject:)
    @NSManaged func removeFromNoteCards(_ value: NoteCard)

    @objc(addNoteCards:)
    @NSManaged func addToNoteCards(_ values: NSSet)

    @objc(removeNoteCards:)
    @NSManaged func removeFromNoteCards(_ values: NSSet)

}


extension Tag {
    
    static func sampleTags(count: Int) -> [Tag] {
        let sampleContext = CoreDataStack.sampleContext
        
        var tags = [Tag]()
        for name in 1...count {
            let tag = Tag(context: sampleContext)
            tag.name = "Tag \(name)"
            tags.append(tag)
        }
        
        return tags
    }
}
