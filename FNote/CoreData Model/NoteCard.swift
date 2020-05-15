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
    
    @NSManaged private(set) var metadata: Metadata
    
    @NSManaged private(set) var uuid: String
    @NSManaged private(set) var native: String
    @NSManaged private(set) var translation: String
    @NSManaged private(set) var isFavorite: Bool
    @NSManaged private(set) var note: String
    @NSManaged private(set) var collection: NoteCardCollection?
    @NSManaged private(set) var relationships: Set<NoteCard>
    @NSManaged private(set) var tags: Set<Tag>
    
    @NSManaged private var formalityValue: Int64
    
    @NSManaged private(set) var linker: NoteCardLinker
    @NSManaged private(set) var linkerTargets: Set<NoteCardLinker>
    
    var formality: Formality {
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


// MARK: - Setter

extension NoteCard {
    
    fileprivate func setNative(_ string: String) {
        native = string.trimmed()
    }
    
    fileprivate func setTranslation(_ string: String) {
        translation = string.trimmed()
    }
    
    fileprivate func setFavorite(_ bool: Bool) {
        isFavorite = bool
    }
    
    fileprivate func setFormality(_ formality: Formality) {
        self.formalityValue = formality.rawValue
    }
    
    fileprivate func setNote(_ string: String) {
        note = string.trimmed()
    }
    
    fileprivate func setCollection(_ collection: NoteCardCollection) {
        self.collection = collection
    }
    
    fileprivate func setRelationships(_ noteCards: Set<NoteCard>) {
        if relationships.contains(self) {
            var relationships = noteCards
            relationships.remove(self)
            self.relationships = relationships
        } else {
            self.relationships = noteCards
        }
    }
    
    fileprivate func addRelationships(_ noteCard: NoteCard) {
        guard noteCard !== self else { return }
        relationships.insert(noteCard)
    }
    
    fileprivate func setTags(_ tags: Set<Tag>) {
        self.tags = tags
    }
    
    fileprivate func addTag(_ tag: Tag) {
        tags.insert(tag)
    }
}


// MARK: - Object Modifier Setter

extension ObjectModifier where Object == NoteCard {
    
    var native: String {
        set { modifiedObject.setNative(newValue) }
        get { modifiedObject.native }
    }
    
    var translation: String {
        set { modifiedObject.setTranslation(newValue) }
        get { modifiedObject.translation }
    }
    
    var isFavorite: Bool {
        set { modifiedObject.setFavorite(newValue) }
        get { modifiedObject.isFavorite }
    }
    
    var formality: NoteCard.Formality {
        set { modifiedObject.setFormality(newValue) }
        get { modifiedObject.formality }
    }
    
    var note: String {
        set { modifiedObject.setNote(newValue) }
        get { modifiedObject.note }
    }
    
    func setCollection(_ collection: NoteCardCollection) {
        let collection = collection.get(from: modifiedContext)
        modifiedObject.setCollection(collection)
    }
    
    func setRelationships(_ noteCards: Set<NoteCard>) {
        let noteCards = noteCards.map({ $0.get(from: modifiedContext) })
        modifiedObject.setRelationships(Set(noteCards))
    }
    
    func addRelationships(_ noteCard: NoteCard) {
        let noteCard = noteCard.get(from: modifiedContext)
        modifiedObject.addRelationships(noteCard)
    }
    
    func setTags(_ tags: Set<Tag>) {
        let tags = tags.map({ $0.get(from: modifiedContext) })
        modifiedObject.setTags(Set(tags))
    }
    
    func addTag(_ tag: Tag) {
        let tag = tag.get(from: modifiedContext)
        modifiedObject.addTag(tag)
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
        let versionField = #keyPath(NoteCard.metadata.version)
        request.predicate = .init(format: "\(versionField) > \(Metadata.previousVersion)")
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
        let versionField = #keyPath(NoteCard.metadata.version)
        
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        let query = "\(collectionUUIDField) == %@ AND \(versionField) > \(Metadata.previousVersion)"
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
            let versionField = #keyPath(NoteCard.metadata.version)
            let query = "\(field.rawValue) CONTAINS[c] %@ AND \(versionField) > \(Metadata.previousVersion)"
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
