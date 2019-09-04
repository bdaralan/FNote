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


public class NoteCardCollection: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteCardCollection> {
        return NSFetchRequest<NoteCardCollection>(entityName: "NoteCardCollection")
    }

    @NSManaged public var name: String
    @NSManaged public var noteCards: Set<NoteCard>
}


extension NoteCardCollection {

    @objc(addNoteCardsObject:)
    @NSManaged public func addToNoteCards(_ value: NoteCard)

    @objc(removeNoteCardsObject:)
    @NSManaged public func removeFromNoteCards(_ value: NoteCard)

    @objc(addNoteCards:)
    @NSManaged public func addToNoteCards(_ values: NSSet)

    @objc(removeNoteCards:)
    @NSManaged public func removeFromNoteCards(_ values: NSSet)

}
