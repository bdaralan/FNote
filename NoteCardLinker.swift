//
//  NoteCardLinker+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 5/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class NoteCardLinker: NSManagedObject {

    @NSManaged private(set) var metadata: Metadata
    
    @NSManaged private(set) var source: NoteCard
    @NSManaged private(set) var targets: Set<NoteCard>
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        metadata = .init(context: managedObjectContext!)
    }
    
    
    func addTarget(_ noteCard: NoteCard) {
        guard noteCard !== source else { return }
        targets.insert(noteCard)
        noteCard.linker.targets.insert(source)
    }
    
    func removeTarget(_ noteCard: NoteCard) {
        guard noteCard !== source else { return }
        targets.remove(noteCard)
        noteCard.linker.targets.remove(source)
    }
}


extension NoteCardLinker {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteCardLinker> {
        return NSFetchRequest<NoteCardLinker>(entityName: "NoteCardLinker")
    }
}
