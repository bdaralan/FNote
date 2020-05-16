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


class NoteCard: NSManagedObject {
    
    @NSManaged fileprivate(set) var metadata: Metadata
    
    @NSManaged fileprivate(set) var uuid: String
    @NSManaged fileprivate(set) var native: String
    @NSManaged fileprivate(set) var translation: String
    @NSManaged fileprivate(set) var isFavorite: Bool
    @NSManaged fileprivate(set) var note: String
    
    @NSManaged fileprivate(set) var collection: NoteCardCollection?
    @NSManaged fileprivate(set) var linker: NoteCardLinker
    @NSManaged fileprivate(set) var tags: Set<Tag>
    
    @NSManaged private var linkerTargets: Set<NoteCardLinker>
    @NSManaged private var formalityValue: Int64
    
    @available(*, deprecated, message: "use link.targets instead.")
    @NSManaged private var relationships: Set<NoteCard>
    
    fileprivate(set) var formality: Formality {
        set { formalityValue = newValue.rawValue }
        get { Formality(rawValue: formalityValue) ?? .unspecified }
    }
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
        metadata = .init(context: managedObjectContext!)
        linker = .init(context: managedObjectContext!)
    }
}


extension NoteCard {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<NoteCard> {
        return NSFetchRequest<NoteCard>(entityName: "NoteCard")
    }
    
    /// A request to fetch no note cards.
    static func requestNone() -> NSFetchRequest<NoteCard> {
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        request.predicate = .init(value: false)
        request.sortDescriptors = []
        return request
    }
    
    static func requestAllNoteCards() -> NSFetchRequest<NoteCard> {
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        let metadataField = #keyPath(NoteCard.metadata)
        request.predicate = .init(format: "\(metadataField) != nil")
        request.sortDescriptors = []
        return request
    }
    
    /// A request to fetch note cards in a collection.
    /// - Parameters:
    ///   - uuid: The collection UUID.
    ///   - predicate: A predicate to match either the `translation` or `native`.
    static func requestNoteCards(collectionUUID: String, sortBy: NoteCard.SearchField = .translation, ascending: Bool = true) -> NSFetchRequest<NoteCard> {
        let collectionUUIDField = #keyPath(NoteCard.collection.uuid)
        let nativeField = #keyPath(NoteCard.native)
        let translationField = #keyPath(NoteCard.translation)
        let metadataField = #keyPath(NoteCard.metadata)
        
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        let query = "\(collectionUUIDField) == %@ AND \(metadataField) != nil"
        request.predicate = NSPredicate(format: query, collectionUUID)
        
        let sortByNative = NSSortDescriptor(key: nativeField, ascending: ascending)
        let sortByTranslation = NSSortDescriptor(key: translationField, ascending: ascending)
        
        switch sortBy {
        case .native:
            request.sortDescriptors = [sortByNative, sortByTranslation]
        case .translation:
            request.sortDescriptors = [sortByTranslation, sortByNative]
        }
        
        return request
    }
    
    /// A request used with search feature to fetch note cards in a collection.
    ///
    /// - Parameters:
    ///   - collectionUUID: The collection UUID. Pass `nil` to search all note cards.
    ///   - searchText: The search text.
    ///   - searchFields: The search scopes.
    ///   - sortBy: The sort field in ascending order.
    /// - Returns: The fetch request. The request will fetch none if any of the parameters are empty.
    static func requestNoteCards(collectionUUID: String?, searchText: String = "", searchFields: [NoteCard.SearchField], sortField: NoteCard.SearchField) -> NSFetchRequest<NoteCard> {
        if searchText.isEmpty || searchFields.isEmpty {
            return NoteCard.requestNone()
        }
        
        // create the request
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        request.sortDescriptors = [.init(key: sortField.rawValue, ascending: true)]
    
        // create predicate for the search scopes
        let fieldPredicates = searchFields.map { field -> NSPredicate in
            let metadataField = #keyPath(NoteCard.metadata)
            let query = "\(field.rawValue) CONTAINS[c] %@ AND \(metadataField) != nil"
            let predicate = NSPredicate(format: query, searchText)
            return predicate
        }
        
        let orFieldsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: fieldPredicates)
        
        // create predicate to match collection uuid
        if let collectionUUID = collectionUUID {
            let collectionUUIDField = #keyPath(NoteCard.collection.uuid)
            let matchCollection = NSPredicate(format: "\(collectionUUIDField) == %@", collectionUUID)
            let predicates = [matchCollection, orFieldsPredicate]
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        } else {
            request.predicate = orFieldsPredicate
        }
        
        return request
    }
    
    static func requestV1NoteCards() -> NSFetchRequest<NoteCard> {
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        let metadataField = #keyPath(NoteCard.metadata)
        request.predicate = .init(format: "\(metadataField) == nil")
        return request
    }
}


// MARK: - Enum

extension NoteCard {
    
    enum SearchField: String {
        case native
        case translation
    }
    
    enum Formality: Int64, CaseIterable {
        case unspecified
        case informal
        case neutral
        case formal
        
        var title: String {
            switch self {
            case .unspecified: return "Undecided"
            case .informal: return "Informal"
            case .neutral: return "Neutral"
            case .formal: return "Formal"
            }
        }
        
        var abbreviation: String {
            switch self {
            case .unspecified: return "U"
            case .informal: return "I"
            case .neutral: return "N"
            case .formal: return "F"
            }
        }
        
        var color: Color {
            Color(uiColor)
        }
        
        var uiColor: UIColor {
            switch self {
            case .unspecified: return .noteCardDivider
            case .informal: return .systemRed
            case .neutral: return .systemOrange
            case .formal: return .systemGreen
            }
        }
    }
}



// MARK: Note Card Modifier

extension ObjectModifier where Object == NoteCard {
    
    var native: String {
        set { modifiedObject.native = newValue.trimmed() }
        get { modifiedObject.native }
    }
    
    var translation: String {
        set { modifiedObject.translation = newValue.trimmed() }
        get { modifiedObject.translation }
    }
    
    var favorited: Bool {
        set { modifiedObject.isFavorite = newValue }
        get { modifiedObject.isFavorite }
    }
    
    var formality: NoteCard.Formality {
        set { modifiedObject.formality = newValue }
        get { modifiedObject.formality }
    }
    
    var note: String {
        set { modifiedObject.note = newValue.trimmed() }
        get { modifiedObject.note }
    }
    
    func setCollection(_ collection: NoteCardCollection) {
        let collection = collection.get(from: modifiedContext)
        modifiedObject.collection = collection
    }
    
    func addRelationship(_ noteCard: NoteCard) {
        let noteCard = noteCard.get(from: modifiedContext)
        modifiedObject.linker.addTarget(noteCard)
    }
    
    func setRelationships(_ noteCards: Set<NoteCard>) {
        let noteCards = noteCards.map({ $0.get(from: modifiedContext) })
        let linker = modifiedObject.linker
        linker.targets.forEach(linker.removeTarget)
        noteCards.forEach(linker.addTarget)
    }
    
    func addTag(_ tag: Tag) {
        let tag = tag.get(from: modifiedContext)
        modifiedObject.tags.insert(tag)
    }
    
    func setTags(_ tags: Set<Tag>) {
        modifiedObject.tags = []
        tags.forEach {
            modifiedObject.tags.insert($0.get(from: modifiedContext))
        }
    }
}
