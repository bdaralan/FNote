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
import SwiftUI


class NoteCard: NSManagedObject, ObjectValidatable {
    
    @NSManaged private(set) var uuid: String
    @NSManaged var native: String
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
    
    
    enum Formality: Int64, CaseIterable {
        case notset
        case informal
        case neutral
        case formal
        
        var title: String {
            switch self {
            case .notset: return "None"
            case .informal: return "Informal"
            case .neutral: return "Neutral"
            case .formal: return "Formal"
            }
        }
        
        var abbreviation: String {
            switch self {
            case .notset: return "?"
            case .informal: return "I"
            case .neutral: return "N"
            case .formal: return "F"
            }
        }
        
        var color: Color {
            switch self {
            case .notset: return .primary
            case .informal: return .red
            case .neutral: return .orange
            case .formal: return .green
            }
        }
    }
}


extension NoteCard {
    
    func isValid() -> Bool {
        hasValidInputs() && collection != nil
    }
    
    func hasValidInputs() -> Bool {
        !native.trimmed().isEmpty && !translation.trimmed().isEmpty
    }
    
    func hasChangedValues() -> Bool {
        hasPersistentChangedValues
    }
    
    func validateData() {
        setPrimitiveValue(native.trimmed(), forKey: #keyPath(NoteCard.native))
        setPrimitiveValue(translation.trimmed(), forKey: #keyPath(NoteCard.translation))
        setPrimitiveValue(note.trimmed(), forKey: #keyPath(NoteCard.note))
    }
}


extension NoteCard {
    
    /// A request to fetch note card in a collection.
    /// - Parameters:
    ///   - uuid: The collection UUID.
    ///   - predicate: A predicate to match either the `translation` or `native`.
    static func requestNoteCards(forCollectionUUID uuid: String, predicate: String = "") -> NSFetchRequest<NoteCard> {
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        let collectionUUID = #keyPath(NoteCard.collection.uuid)
        let native = #keyPath(NoteCard.native)
        let translation = #keyPath(NoteCard.translation)
        
        let matchCollection = NSPredicate(format: "\(collectionUUID) == %@", uuid)
        
        if predicate.trimmed().isEmpty {
            request.predicate = matchCollection
        } else {
            let query = "\(translation) CONTAINS[c] %@ OR \(native) CONTAINS[c] %@"
            let matchTranslationOrNative = NSPredicate(format: query, predicate, predicate)
            let predicates = [matchCollection, matchTranslationOrNative]
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = [.init(key: translation, ascending: true)]
        
        return request
    }
    
    static func requestNone() -> NSFetchRequest<NoteCard> {
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        request.predicate = .init(value: false)
        request.sortDescriptors = []
        return request
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


extension NoteCard {
    
    static func sampleNoteCards(count: Int) -> [NoteCard] {
        let sampleContext = CoreDataStack.sampleContext
        
        var notes = [NoteCard]()
        for note in 1...count {
            let noteCard = NoteCard(context: sampleContext)
            noteCard.native = "Native \(note)"
            noteCard.translation = "Translation \(note)"
            notes.append(noteCard)
        }
        
        return notes
    }
}
