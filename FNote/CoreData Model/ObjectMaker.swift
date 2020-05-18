//
//  ObjectMaker.swift
//  FNote
//
//  Created by Dara Beng on 5/5/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


class ObjectMaker {
        
    let context: NSManagedObjectContext
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}


// MARK: - Object V1 to V2

extension ObjectMaker {
    
    /// - Parameter collection: The version 1 collection.
    static func importV1Collections(_ collections: [NoteCardCollection], using context: NSManagedObjectContext, prefix: String) {
        var collectionMap = [NoteCardCollection: NoteCardCollection]() // [old: new]
        var cardMap = [NoteCard: NoteCard]() // [old: new]
        var tagMap = [Tag: Tag]() // [old: new]
        
        let allV2Tags = try! context.fetch(Tag.requestAllTags())
        
        // CREATE Objects without assigning values
        for collection in collections {
            let newCollection = NoteCardCollection(context: context)
            collectionMap[collection] = newCollection
            
            for noteCard in collection.noteCards {
                let newNoteCard = NoteCard(context: context)
                cardMap[noteCard] = newNoteCard
                
                for tag in noteCard.tags {
                    guard tagMap[tag] == nil else { continue }
                    if let v2Tag = allV2Tags.first(where: { $0.name.lowercased() == tag.name.lowercased() }) {
                        tagMap[tag] = v2Tag
                    } else {
                        let newTag = Tag(context: context)
                        tagMap[tag] = newTag
                    }
                }
            }
        }
        
        // Assign Objects' values and relationship
        for collection in collections {
            // create new collection
            let newCollection = collectionMap[collection]!
            var collectionModifier = ObjectModifier<NoteCardCollection>(.update(newCollection), useSeparateContext: false)
            collectionModifier.name = "\(prefix)\(collection.name)"
            
            // create new note cards for collection
            for noteCard in collection.noteCards {
                let newNoteCard = cardMap[noteCard]!
                collectionModifier.addNoteCard(newNoteCard)
                
                var cardModifier = ObjectModifier<NoteCard>(.update(newNoteCard), useSeparateContext: false)
                cardModifier.native = noteCard.native
                cardModifier.translation = noteCard.translation
                cardModifier.favorited = noteCard.isFavorite
                cardModifier.note = noteCard.note
                cardModifier.formality = noteCard.formality
                
                let oldRelationships = noteCard.value(forKey: "relationships") as? Set<NoteCard> ?? []
                for relationship in oldRelationships {
                    let relationship = cardMap[relationship]!
                    cardModifier.addRelationship(relationship)
                }
                
                // create new tags for note card
                for tag in noteCard.tags {
                    let newTag = tagMap[tag]!
                    var tagModifier = ObjectModifier<Tag>(.update(newTag), useSeparateContext: false)
                    tagModifier.name = tag.name
                    cardModifier.addTag(newTag)
                }
            }
        }
    }
}


// MARK: - Import Public Record

extension ObjectMaker {
    
    func importPublicCollection(_ collection: PublicCollection, completion: @escaping (NoteCardCollection?) -> Void) {
        let recordManager = PublicRecordManager.shared
        recordManager.queryCards(withCollectionID: collection.collectionID) { result in
            guard case let .success(records) = result else {
                completion(nil)
                return
            }
            
            let cards = records.map({ PublicCard(record: $0) })
            let collectionName = "\(collection.name) by \(collection.authorName)"
            let collection = self.makeNoteCardCollection(name: collectionName, with: cards)
            completion(collection)
        }
    }
}


// MARK: - Object to Record

extension ObjectMaker {
    
    /// Make public cards from the given note cards.
    /// - Parameters:
    ///   - noteCards: The note cards used to make public cards.
    ///   - collectionID: The public collection ID for the public cards.
    ///   - includeNote: The value indicates whether to include card's note.
    /// - Returns: An arrow of public cards.
    static func makePublicCards(from noteCards: Set<NoteCard>, collectionID: String, includeNote: Bool) -> [PublicCard] {
        // create ID map for public card and use it to set relationships
        // map value is [localID: publicID]
        var cardIDMap = [String: String]()
        for noteCard in noteCards {
            let localID = noteCard.uuid
            let publicID = UUID().uuidString
            cardIDMap[localID] = publicID
        }
        
        // unwrapping the map is safe here
        let publicCards = noteCards.map { noteCard -> PublicCard in
            let localID = noteCard.uuid
            let publicID = cardIDMap[localID]!
            let publicTags = noteCard.tags.map(\.name).sorted()
            let publicNote = includeNote ? noteCard.note : ""
            
            let publicRelationshipIDs = noteCard.linker.targets.compactMap { relationship -> String? in
                guard noteCard.collection === relationship.collection else { return nil }
                return cardIDMap[relationship.uuid]!
            }
            
            let publicCard = PublicCard(
                collectionID: collectionID,
                cardID: publicID,
                native: noteCard.native,
                translation: noteCard.translation,
                favorited: noteCard.isFavorite,
                formality: noteCard.formality,
                note: publicNote,
                tags: publicTags,
                relationships: publicRelationshipIDs
            )
            
            return publicCard
        }
        
        return publicCards
    }
}


// MARK: - Record to Object

extension ObjectMaker {
    
    /// Make `NoteCardCollection` with the given public cards.
    /// - Parameters:
    ///   - name: The name of the collection.
    ///   - cards: The public cards to make into note cards.
    /// - Returns: The newly made collection.
    func makeNoteCardCollection(name: String, with cards: [PublicCard]) -> NoteCardCollection {
        var modifier = ObjectModifier<NoteCardCollection>(.create(in: context), useSeparateContext: false)
        modifier.name = name
        
        let noteCards = self.makeNoteCards(from: cards)
        for noteCard in noteCards {
            modifier.addNoteCard(noteCard)
        }
        
        return modifier.modifiedObject
    }
    
    /// Make `NoteCard` objects from the given `PublicCard`.
    ///
    /// - Note: This also create tags and relationships.
    ///
    /// - Parameter cards: The fully loaded public cards.
    ///
    /// - Returns: The made note cards with tags and relationships.
    func makeNoteCards(from cards: [PublicCard]) -> [NoteCard] {
        let tagMap = makeTagMap(from: cards)
        let cardMap = makeNoteCardMap(from: cards)
        
        // Note:
        // the forced unwraps are intentional
        // if the value is not there, the logic is wrong
        // crash the app so that the generating process failed
        
        // Future Note:
        // use 'if let' if the database allows deleting some cards
        // and the relationships property is updated incorrectly
        // but ideally the database should delete the relationships accordingly
        
        for card in cards {
            let noteCard = cardMap[card.cardID]!
            var modifier = ObjectModifier<NoteCard>(.update(noteCard), useSeparateContext: false)
            modifier.native = card.native
            modifier.translation = card.translation
            modifier.formality = card.formality
            modifier.favorited = card.favorited
            modifier.note = card.note
            
            card.tags.forEach { tagName in
                let tag = tagMap[tagName]!
                modifier.addTag(tag)
            }
            
            card.relationships.forEach { relationshipID in
                let noteCard = cardMap[relationshipID]!
                modifier.addRelationship(noteCard)
            }
        }
        
        return cardMap.values.map({ $0 })
    }
    
    /// Make a map containing `Tag`.
    ///
    /// - Parameter cards: The cards with all the tags.
    ///
    /// - Returns: A map where key is the tag's name and value is the `Tag` object.
    private func makeTagMap(from cards: [PublicCard]) -> [String: Tag] {
        var result = [String: Tag]() // [name: Tag]
        
        let publicTags = Set(cards.map(\.tags).reduce([], +))
        let localTags = try! context.fetch(Tag.requestAllTags())
        
        for tagName in publicTags {
            if let localTag = localTags.first(where: { $0.name == tagName }) {
                result[tagName] = localTag
            } else {
                var modifier = ObjectModifier<Tag>(.create(in: context), useSeparateContext: false)
                modifier.name = tagName
                result[tagName] = modifier.modifiedObject
            }
        }
        
        return result
    }
    
    /// Make a map containing `NoteCard`.
    ///
    /// - Parameter cards: The cards to make from.
    ///
    /// - Returns: A map where key is the card's ID and value is the `NoteCard` object.
    private func makeNoteCardMap(from cards: [PublicCard]) -> [String: NoteCard] {
        var result = [String: NoteCard]() // [cardID: NoteCard]
        
        for card in cards {
            let modifier = ObjectModifier<NoteCard>(.create(in: context), useSeparateContext: false)
            result[card.cardID] = modifier.modifiedObject
        }
        
        return result
    }
}
