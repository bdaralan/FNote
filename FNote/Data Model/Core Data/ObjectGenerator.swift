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
            modifier.isFavorite = card.favorited
            modifier.note = card.note
            
            card.tags.forEach { tagName in
                let tag = tagMap[tagName]!
                modifier.addTag(tag)
            }
            
            card.relationships.forEach { relationshipID in
                let noteCard = cardMap[relationshipID]!
                modifier.addRelationships(noteCard)
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
