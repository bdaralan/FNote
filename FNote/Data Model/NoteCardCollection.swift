//
//  NoteCardCollection+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class NoteCardCollection: NSManagedObject, ObjectValidatable {

    @NSManaged var name: String
    @NSManaged var noteCards: Set<NoteCard>
}


extension NoteCardCollection {
    
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


extension NoteCardCollection {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<NoteCardCollection> {
        return NSFetchRequest<NoteCardCollection>(entityName: "NoteCardCollection")
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
