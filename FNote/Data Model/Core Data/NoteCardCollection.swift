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


class NoteCardCollection: NSManagedObject, Identifiable, ObjectValidatable {

    @NSManaged private(set) var uuid: String
    @NSManaged var name: String
    @NSManaged var noteCards: Set<NoteCard>
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
    }
    
    override func willSave() {
        if !isDeleted {
            validateData()
        }
        super.willSave()
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
    
    func setName(_ string: String) {
        modifiedObject.setName(string)
    }
    
    func addNoteCard(_ noteCard: NoteCard) {
        let noteCard = noteCard.get(from: modifiedContext)
        modifiedObject.addNoteCard(noteCard)
    }
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
        setPrimitiveValue(name.trimmedComma(), forKey: #keyPath(NoteCardCollection.name))
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
