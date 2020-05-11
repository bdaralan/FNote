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


class NoteCardCollection: NSManagedObject {

    @NSManaged private(set) var uuid: String
    @NSManaged private(set) var name: String
    @NSManaged private(set) var noteCards: Set<NoteCard>
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
    }
}


// MARK: - Setter

extension NoteCardCollection {
    
    fileprivate func setName(_ string: String) {
        name = string.trimmed()
    }
    
    fileprivate func addNoteCard(_ noteCard: NoteCard) {
        noteCards.insert(noteCard)
    }
}


// MARK: - Object Modifier Setter

extension ObjectModifier where Object == NoteCardCollection {
    
    var name: String {
        set { modifiedObject.setName(newValue) }
        get { modifiedObject.name }
    }
    
    func addNoteCard(_ noteCard: NoteCard) {
        let noteCard = noteCard.get(from: modifiedContext)
        modifiedObject.addNoteCard(noteCard)
    }
}


extension NoteCardCollection {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<NoteCardCollection> {
        return NSFetchRequest<NoteCardCollection>(entityName: "NoteCardCollection")
    }
    
    static func requestAllCollections() -> NSFetchRequest<NoteCardCollection> {
        let request = NoteCardCollection.fetchRequest() as NSFetchRequest<NoteCardCollection>
        let nameField = #keyPath(NoteCardCollection.name)
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: nameField, ascending: true)]
        return request
    }
}
