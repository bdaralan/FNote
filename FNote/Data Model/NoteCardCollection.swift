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
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<NoteCardCollection> {
        return NSFetchRequest<NoteCardCollection>(entityName: "NoteCardCollection")
    }
    
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
    
    /// Check if a name already exists in the context.
    /// - Parameters:
    ///   - name: The name to check. The name is case sensitive.
    ///   - context: The context to check.
    /// - Returns: `true` if the name is in the context or if failed to check.
    static func isNameExisted(name: String, in context: NSManagedObjectContext) -> Bool {
        let request = requestAllCollections()
        guard let collections = try? context.fetch(request) else { return true }
        let names = collections.map({ $0.name })
        return names.contains(name)
    }
}


extension NoteCardCollection {
    
    static let sample: NoteCardCollection = {
        let collection = NoteCardCollection(context: .sample)
        collection.name = "Sample Collection"
        return collection
    }()
}
