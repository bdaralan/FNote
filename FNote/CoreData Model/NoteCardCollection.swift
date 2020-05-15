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

    @NSManaged fileprivate(set) var metadata: Metadata
    
    @NSManaged fileprivate(set) var uuid: String
    @NSManaged fileprivate(set) var name: String
    @NSManaged fileprivate(set) var noteCards: Set<NoteCard>
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
        metadata = .init(context: managedObjectContext!)
    }
}


extension NoteCardCollection {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<NoteCardCollection> {
        return NSFetchRequest<NoteCardCollection>(entityName: "NoteCardCollection")
    }
    
    static func requestAllCollections() -> NSFetchRequest<NoteCardCollection> {
        let request = NoteCardCollection.fetchRequest() as NSFetchRequest<NoteCardCollection>
        let nameField = #keyPath(NoteCardCollection.name)
        let versionField = #keyPath(NoteCardCollection.metadata.version)
        request.predicate = .init(format: "\(versionField) > \(Metadata.previousVersion)")
        request.sortDescriptors = [.init(key: nameField, ascending: true)]
        return request
    }
    
    static func requestV1NoteCardCollections() -> NSFetchRequest<NoteCardCollection> {
        let request = NoteCardCollection.fetchRequest() as NSFetchRequest<NoteCardCollection>
        let metadataField = #keyPath(NoteCardCollection.metadata)
        request.predicate = .init(format: "\(metadataField) == nil")
        return request
    }
}


// MARK: - Object Modifier Setter

extension ObjectModifier where Object == NoteCardCollection {
    
    var name: String {
        set { modifiedObject.name = newValue.trimmed() }
        get { modifiedObject.name }
    }
    
    func addNoteCard(_ noteCard: NoteCard) {
        let noteCard = noteCard.get(from: modifiedContext)
        modifiedObject.noteCards.insert(noteCard)
    }
}
