//
//  ObjectGenerator.swift
//  FNote
//
//  Created by Dara Beng on 5/5/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


class ObjectGenerator {
        
    let context: NSManagedObjectContext
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}


// MARK: - Record to Object

extension ObjectGenerator {
    
    /// Generator `NoteCard` objects from the given `PublicCard`.
    ///
    /// - Note: This also create tags and relationships.
    ///
    /// - Parameter cards: The fully loaded public cards.
    ///
    /// - Returns: The generated note card with tags and relationships.
    func generateNoteCards(from cards: [PublicCard]) -> [NoteCard] {
        let tagMap = generateTagMap(from: cards)
        let cardMap = generateNoteCardMap(from: cards)
        
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
    
    /// Generate a map containing `Tag`.
    ///
    /// - Parameter cards: The cards with all the tags.
    ///
    /// - Returns: A map where key is the tag's name and value is the `Tag` object.
    private func generateTagMap(from cards: [PublicCard]) -> [String: Tag] {
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
    
    /// Generate a map containing `NoteCard`.
    ///
    /// - Parameter cards: The cards to generate from.
    ///
    /// - Returns: A map where key is the card's ID and value is the `NoteCard` object.
    private func generateNoteCardMap(from cards: [PublicCard]) -> [String: NoteCard] {
        var result = [String: NoteCard]() // [cardID: NoteCard]
        
        for card in cards {
            let modifier = ObjectModifier<NoteCard>(.create(in: context), useSeparateContext: false)
            result[card.cardID] = modifier.modifiedObject
        }
        
        return result
    }
}


// MARK: - Object V1 to V2

extension ObjectGenerator {
    
    /// - Parameter collection: The version 1 collection.
    static func importV1Collections(_ collections: [NoteCardCollection], using context: NSManagedObjectContext) {
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
            collectionModifier.name = "[imported] \(collection.name)"
            
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


// MARK: - Object to Record

extension ObjectGenerator {
    
    static func generatePublicCards(from noteCards: Set<NoteCard>, collectionID: String, includeNote: Bool) -> [PublicCard] {
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
