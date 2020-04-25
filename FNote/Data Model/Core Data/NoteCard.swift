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


class NoteCard: NSManagedObject, Identifiable, ObjectValidatable {
    
    @NSManaged private(set) var uuid: String
    @NSManaged var native: String
    @NSManaged var translation: String
    @NSManaged var isFavorite: Bool
    @NSManaged var note: String
    @NSManaged var collection: NoteCardCollection?
    @NSManaged private(set) var relationships: Set<NoteCard>
    @NSManaged private(set) var tags: Set<Tag>
    
    @NSManaged private var formalityValue: Int64
    
    var formality: Formality {
        set { formalityValue = newValue.rawValue }
        get { Formality(rawValue: formalityValue) ?? .unspecified }
    }
    
    
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
    
    func setNative(_ string: String) {
        modifiedObject.setNative(string)
    }
    
    func setTranslation(_ string: String) {
        modifiedObject.setTranslation(string)
    }
    
    func setFavorite(_ bool: Bool) {
        modifiedObject.setFavorite(bool)
    }
    
    func setFormality(_ formality: NoteCard.Formality) {
        modifiedObject.setFormality(formality)
    }
    
    func setNote(_ string: String) {
        modifiedObject.setNote(string)
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
        setPrimitiveValue(formality.rawValue, forKey: #keyPath(NoteCard.formalityValue))
        setPrimitiveValue(native.trimmed(), forKey: #keyPath(NoteCard.native))
        setPrimitiveValue(translation.trimmed(), forKey: #keyPath(NoteCard.translation))
        setPrimitiveValue(note.trimmed(), forKey: #keyPath(NoteCard.note))
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
        request.predicate = .init(value: true)
        request.sortDescriptors = []
        return request
    }
    
    /// A request to fetch note cards in a collection.
    /// - Parameters:
    ///   - uuid: The collection UUID.
    ///   - predicate: A predicate to match either the `translation` or `native`.
    static func requestNoteCards(collectionUUID: String, sortBy: NoteCardSortField = .translation, ascending: Bool = true) -> NSFetchRequest<NoteCard> {
        let collectionUUIDField = #keyPath(NoteCard.collection.uuid)
        let nativeField = #keyPath(NoteCard.native)
        let translationField = #keyPath(NoteCard.translation)
        
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        request.predicate = NSPredicate(format: "\(collectionUUIDField) == %@", collectionUUID)
        
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
    ///   - uuid: The collection UUID.
    ///   - searchText: The search text.
    ///   - scopes: The search scopes.
    /// - Returns: The fetch request. The request will fetch none if any of the parameters are empty.
    static func requestNoteCards(collectionUUID: String, searchText: String = "", searchFields: [NoteCardSearchField]) -> NSFetchRequest<NoteCard> {
        guard searchText.trimmed().isEmpty == false, searchFields.isEmpty == false else { return NoteCard.requestNone() }
        
        // create predicate for the search scopes
        var fieldPredicates = [NSPredicate]()
        for field in searchFields {
            let predicate = NSPredicate(format: "\(field.rawValue) CONTAINS[c] %@", searchText)
            fieldPredicates.append(predicate)
        }
        
        // create predicate to match collection uuid
        let collectionUUIDField = #keyPath(NoteCard.collection.uuid)
        let matchCollection = NSPredicate(format: "\(collectionUUIDField) == %@", collectionUUID)
        
        // combine the predicates
        // OR the scopes then AND with the match collection's uuid
        let fieldCompoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: fieldPredicates)
        let allPredicates = [matchCollection, fieldCompoundPredicate]
        let requestPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
        
        // create the request
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        let sortKey = #keyPath(NoteCard.translation)
        request.predicate = requestPredicate
        request.sortDescriptors = [.init(key: sortKey, ascending: true)]
        
        return request
    }
}


extension NoteCard {
    
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
