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
    @NSManaged var relationships: Set<NoteCard>
    @NSManaged var tags: Set<Tag>
    
    @NSManaged private var formalityValue: Int64
    
    var formality: Formality {
        set { formalityValue = newValue.rawValue }
        get { Formality(rawValue: formalityValue)! }
    }
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = "FNNC+\(UUID().uuidString)"
    }
    
    override func willSave() {
        if !isDeleted {
            validateData()
        }
        super.willSave()
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
    
    func addRelationships(_ noteCards: Set<NoteCard>) {
        for noteCard in noteCards where noteCard !== self {
            relationships.insert(noteCard)
        }
    }
    
    func addTags(_ tags: Set<Tag>) {
        for tag in tags {
            self.tags.insert(tag)
        }
    }
    
    func setTags(_ tags: Set<Tag>) {
        self.tags = tags
    }
    
    func setRelationships(_ relationships: Set<NoteCard>) {
        self.relationships = relationships
        self.relationships.remove(self)
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
    
    /// A request to fetch favorited note cards in a collection.
    /// - Parameter uuid: The collection UUID. The default is `nil` means fetch all favorited note cards.
    static func requestFavoriteCards(forCollectionUUID uuid: String? = nil) -> NSFetchRequest<NoteCard> {
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        let isFavorited = #keyPath(NoteCard.isFavorite)
        let translation = #keyPath(NoteCard.translation)
        let collectionUUID = #keyPath(NoteCard.collection.uuid)
        
        var predicates = [NSPredicate]()
        
        if let uuid = uuid, !uuid.isEmpty {
            let matchCollection = NSPredicate(format: "\(collectionUUID) == %@", uuid)
            predicates.append(matchCollection)
        }
        
        let matchFavorited = NSPredicate(format: "\(isFavorited) == true")
        predicates.append(matchFavorited)
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [.init(key: translation, ascending: true)]
        return request
    }
    
    /// A request to fetch note cards in a collection.
    /// - Parameters:
    ///   - uuid: The collection UUID.
    ///   - predicate: A predicate to match either the `translation` or `native`.
    static func requestNoteCards(forCollectionUUID uuid: String, sortBy: NoteCardSortOption = .translation, ascending: Bool = true) -> NSFetchRequest<NoteCard> {
        guard !uuid.trimmed().isEmpty else { return NoteCard.requestNone() }
        
        let collectionUUID = #keyPath(NoteCard.collection.uuid)
        let native = #keyPath(NoteCard.native)
        let translation = #keyPath(NoteCard.translation)
        
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        request.predicate = NSPredicate(format: "\(collectionUUID) == %@", uuid)
        
        let sortByNative = NSSortDescriptor(key: native, ascending: ascending)
        let sortByTranslation = NSSortDescriptor(key: translation, ascending: ascending)
        
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
    static func requestNoteCards(forCollectionUUID uuid: String, searchText: String = "", scopes: [NoteCardSearchScope]) -> NSFetchRequest<NoteCard> {
        guard !uuid.trimmed().isEmpty, !searchText.trimmed().isEmpty, !scopes.isEmpty else { return NoteCard.requestNone() }
        
        // create predicate for the search scopes
        var scopePredicates = [NSPredicate]()
        for scope in scopes {
            let predicate = NSPredicate(format: "\(scope.keyPath) CONTAINS[c] %@", searchText)
            scopePredicates.append(predicate)
        }
        
        // create predicate to match collection uuid
        let collectionUUID = #keyPath(NoteCard.collection.uuid)
        let matchCollection = NSPredicate(format: "\(collectionUUID) == %@", uuid)
        
        // combine the predicates
        // OR the scopes then AND with the match collection's uuid
        let scopeCompoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: scopePredicates)
        let allPredicates = [matchCollection, scopeCompoundPredicate]
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
            case .unspecified: return UIColor(named: "note-card-divider")!
            case .informal: return .systemRed
            case .neutral: return .systemOrange
            case .formal: return .systemGreen
            }
        }
    }
}


extension NoteCard {
    
    static let sample: NoteCard = {
        let card = NoteCard(context: .sample)
        card.native = "Native"
        card.translation = "Translation"
        return card
    }()
}
