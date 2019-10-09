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

    @NSManaged private(set) var uuid: String
    @NSManaged var name: String
    @NSManaged var noteCards: Set<NoteCard>
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
    }
    
    override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        objectWillChange.send()
    }
    
    override func willSave() {
        if !isDeleted {
            validateData()
        }
        super.willSave()
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
        setPrimitiveValue(name.trimmed(), forKey: #keyPath(NoteCardCollection.name))
    }
}


extension NoteCardCollection {
    
    static func requestCollection(withUUID uuid: String) -> NSFetchRequest<NoteCardCollection> {
        let request = NoteCardCollection.fetchRequest() as NSFetchRequest<NoteCardCollection>
        let collectionUUID = #keyPath(NoteCardCollection.uuid)
        request.predicate = .init(format: "\(collectionUUID) == %@", uuid)
        request.sortDescriptors = []
        return request
    }
    
    static func requestAllCollections() -> NSFetchRequest<NoteCardCollection> {
        let request = NoteCardCollection.fetchRequest() as NSFetchRequest<NoteCardCollection>
        let collectionName = #keyPath(NoteCardCollection.name)
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: collectionName, ascending: true)]
        return request
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


extension NoteCardCollection {
    
    static func sampleCollections(count: Int, noteCount: Int) -> [NoteCardCollection] {
        let sampleContext = CoreDataStack.sampleContext
        
        var collections = [NoteCardCollection]()
        for name in 1...count {
            let collection = NoteCardCollection(context: sampleContext)
            collection.name = "Collection \(name)"
            
            for noteName in 1...noteCount {
                let note = NoteCard(context: sampleContext)
                note.native = "Navitve \(noteName)"
                note.translation = "Translation: \(noteName)"
                note.collection = collection
            }
            
            collections.append(collection)
        }
        return collections
    }
}
